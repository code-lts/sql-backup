#!/bin/bash

# from : github:builtinnya/dotenv-shell-loader
DOTENV_SHELL_LOADER_SAVED_OPTS=$(set +o)
set -o allexport
if [ ! -z "${BACKUP_CONFIG_ENVFILE}" ]; then
    if [ ! -f "${BACKUP_CONFIG_ENVFILE}" ]; then
        echo "Value of variable BACKUP_CONFIG_ENVFILE is not a file (${BACKUP_CONFIG_ENVFILE})"
        exit 1
    else
      [ -f "${BACKUP_CONFIG_ENVFILE}" ] && source "${BACKUP_CONFIG_ENVFILE}"
    fi
else
  [ -f "$(dirname $0)/.env" ] && source "$(dirname $0)/.env"
fi
set +o allexport
eval "$DOTENV_SHELL_LOADER_SAVED_OPTS"
unset DOTENV_SHELL_LOADER_SAVED_OPTS

if ! [ -x "$(command -v mysql)" ]; then
  echo 'Error: mysql is not installed !, apt-get install -y mysql-client' >&2
  exit 1
fi

if ! [ -x "$(command -v mysqldump)" ]; then
  echo 'Error: mysqldump is not installed !, apt-get install -y mysql-client' >&2
  exit 1
fi

if [ -z "${BACKUP_DIR}" ]; then
    echo "Empty Variable BACKUP_DIR"
    exit 1
else
  if [ ! -d "${BACKUP_DIR}" ]; then
      echo "Value of variable BACKUP_DIR is not a directory (${BACKUP_DIR})"
      exit 1
  fi
fi

if [ -z "${MYSQL_HOST}" ]; then
    echo "Empty Variable MYSQL_HOST"
    exit 1
fi

if [ -z "${MYSQL_USER}" ]; then
    echo "Empty Variable MYSQL_USER"
    exit 1
fi


MYSQL_CONN="-h${MYSQL_HOST} -u${MYSQL_USER}"

if [ ! -z "${MYSQL_PASS}" ]; then
    MYSQL_CONN="${MYSQL_CONN} -p${MYSQL_PASS}"
fi

if [ -z "${EXPERT_ARGS}" ]; then
    EXPERT_ARGS="--default-character-set=utf8 --extended-insert=FALSE --single-transaction --skip-comments --skip-dump-date --hex-blob --tz-utc"
fi

MYSQLDUMP_DEFAULTS="${MYSQL_CONN} ${EXPERT_ARGS}"

DB_LIST_SQL="SELECT schema_name FROM information_schema.schemata"

# If ${SKIP_DATABASES} is not empty, create a where chain 
if [ ! -z "${SKIP_DATABASES}" ]; then
    DB_LIST_SQL="${DB_LIST_SQL} WHERE schema_name NOT IN ("
    # Split on ,
    SKIP_DATABASES=$(echo -e "${SKIP_DATABASES}" | tr "," "\n")
    for DB in ${SKIP_DATABASES} ; do
    DB_LIST_SQL="${DB_LIST_SQL}'${DB}'," ;
    done
    DB_LIST_SQL="${DB_LIST_SQL: : -1}"
    DB_LIST_SQL="${DB_LIST_SQL});"
fi
#    echo -e "${DB_LIST_SQL}"
# Get result
DB_LIST=`mysql ${MYSQL_CONN} -ANe"${DB_LIST_SQL}"`

for DB in $DB_LIST; do # Concat ignore command
    DBS="${DBS} ${DB}"
done

VIEW_LIST_SQL="SET SESSION group_concat_max_len = 1000000;SELECT GROUP_CONCAT(concat(':!\`',table_schema,'\`.\`',table_name,'\`') SEPARATOR '') FROM information_schema.views"
# Get result
VIEWS_LIST=`mysql ${MYSQL_CONN} -ANe"${VIEW_LIST_SQL}"`

VIEW_IGNORE_ARG=""
# Split on :!
VIEWS=$(echo -e "${VIEWS_LIST}" | tr ":!" "\n")

for VIEW in $VIEWS; do # Concat ignore command
    VIEW_IGNORE_ARG="${VIEW_IGNORE_ARG} --ignore-table=${VIEW}"
done
# Replace ` in ${VIEW_IGNORE_ARG}, does not work with ` in table/database names
VIEW_IGNORE_ARG=${VIEW_IGNORE_ARG//\`/}
# echo -e "${VIEW_IGNORE_ARG}"

echo "Structure..."
mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=FALSE --events=FALSE --no-data ${VIEW_IGNORE_ARG} --databases ${DBS} > ${BACKUP_DIR}/structure.sql

echo "Data ..."
mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=FALSE --events=FALSE --no-create-info ${VIEW_IGNORE_ARG} --databases ${DBS} > ${BACKUP_DIR}/database.sql

echo "Users ..."
mysqldump ${MYSQLDUMP_DEFAULTS} mysql --no-create-info --complete-insert --tables user db > ${BACKUP_DIR}/users.sql

echo "Routines ..."
mysqldump ${MYSQLDUMP_DEFAULTS} --routines=TRUE --triggers=FALSE --events=FALSE --no-create-info --no-data --no-create-db --databases ${DBS} > ${BACKUP_DIR}/routines.sql

echo "Triggers ..."
mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=TRUE --events=FALSE --no-create-info --no-data --no-create-db --databases ${DBS} > ${BACKUP_DIR}/triggers.sql

echo "Events ..."
mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=FALSE --events=TRUE --no-create-info --no-data --no-create-db --databases ${DBS} > ${BACKUP_DIR}/events.sql

echo "Views ..."
VIEWS_SHOW_SQL=""
for VIEW in $VIEWS; do # Concat SHOW CREATE VIEW command
    VIEWS_SHOW_SQL="${VIEWS_SHOW_SQL}SHOW CREATE VIEW ${VIEW};"
done
# echo -e "${VIEWS_SHOW_SQL}"
echo ${VIEWS_SHOW_SQL} | sed 's/;/\\G/g' | mysql ${MYSQL_CONN} > ${BACKUP_DIR}/views.sql

#Keeps lines starting with Create
sed -i '/Create/!d' ${BACKUP_DIR}/views.sql
# Removes 'Create View'
sed -i -e 's/Create\ View://g' ${BACKUP_DIR}/views.sql
#add ; at lines end
sed -i 's/)$/);/' ${BACKUP_DIR}/views.sql
#Remove spaces before start of line
sed -i 's/^ *//' ${BACKUP_DIR}/views.sql
#Add ; at line end
sed -i 's/$/;/' ${BACKUP_DIR}/views.sql
#Replace double ;; by ;
sed -i 's/;;/;/' ${BACKUP_DIR}/views.sql

echo "Grants ..."
# Needs refactor
GRANTS_SQL="select distinct concat( \"SHOW GRANTS FOR '\",user,\"'@'\",host,\"';\" ) from mysql.user WHERE user != 'root';"
GRANTS_LIST=`mysql ${MYSQL_CONN} -ANe"${GRANTS_SQL}"`
echo ${GRANTS_LIST} | mysql --default-character-set=utf8 --skip-comments ${MYSQL_CONN} | sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 --/;/--/{x;p;x;}' > ${BACKUP_DIR}/grants.sql
# Removes double backslashes >  \\
sed -i -e 's/\\\\//g' ${BACKUP_DIR}/grants.sql
# echo -e ${GRANTS_SQL}

echo "Backup done !"
if [ ! -z "${ON_SUCCESS}" ]; then
`echo ${ON_SUCCESS}`
fi
