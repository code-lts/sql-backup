#!/bin/bash

exitWithMsg() {
  echo $2
  exit $1
}

hasSkip() {
  for e in "${SKIP_OP[@]}"; do
    if [ "$e" == "$1" ]; then
      return 1
    fi
  done
  return 0
}

# from : github:builtinnya/dotenv-shell-loader
DOTENV_SHELL_LOADER_SAVED_OPTS=$(set +o)
set -o allexport
if [ ! -z "${BACKUP_CONFIG_ENVFILE}" ]; then
    if [ ! -f "${BACKUP_CONFIG_ENVFILE}" ]; then
        exitWithMsg 201 "Value of variable BACKUP_CONFIG_ENVFILE is not a file (${BACKUP_CONFIG_ENVFILE})"
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
  exitWithMsg 203 'Error: mysql is not installed !, apt-get install -y mysql-client' >&2
fi

if ! [ -x "$(command -v mysqldump)" ]; then
  exitWithMsg 203 'Error: mysqldump is not installed !, apt-get install -y mysql-client' >&2
fi

if [ -z "${BACKUP_DIR}" ]; then
    exitWithMsg 200 "Empty Variable BACKUP_DIR"
else
  if [ ! -d "${BACKUP_DIR}" ]; then
      exitWithMsg 202 "Value of variable BACKUP_DIR is not a directory (${BACKUP_DIR})"
  fi
fi

if [ -z "${MYSQL_HOST}" ]; then
    exitWithMsg 200 "Empty Variable MYSQL_HOST"
fi

if [ -z "${MYSQL_USER}" ]; then
    exitWithMsg 200 "Empty Variable MYSQL_USER"
fi

if [ -z "${SKIP_OP}" ]; then
    SKIP_OP=()
else
  SKIP_OPS=$(echo -e "${SKIP_OP}" | tr "," "\n")
  SKIP_OP=()
  oldIFS=$IFS
  IFS=$'\n'
  for SKIP in $SKIP_OPS; do
    SKIP_OP+=(${SKIP} )
  done
  IFS=$oldIFS
fi

MYSQL_CONN="-h${MYSQL_HOST} -u${MYSQL_USER} --port ${MYSQL_PORT:-3306}"

if [ ! -z "${MYSQL_PASS}" ]; then
    MYSQL_CONN="${MYSQL_CONN} -p${MYSQL_PASS} --port ${MYSQL_PORT:-3306}"
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
DB_LIST=$(mysql ${MYSQL_CONN} -ANe"${DB_LIST_SQL}")

if [ "$?" -ne 0 ]; then
  exitWithMsg 204 "Databases listing failed"
fi

if [ -z "${DB_LIST}" ]; then
  exitWithMsg 206 "No databases to backup"
fi

for DB in $DB_LIST; do # Concat ignore command
    DBS="${DBS} ${DB}"
done

hasSkip "views"
if [ "$?" -eq 0 ]; then
  VIEW_LIST_SQL="SET SESSION group_concat_max_len = 1000000;SELECT IFNULL(GROUP_CONCAT(concat(':!\`',table_schema,'\`.\`',table_name,'\`') SEPARATOR ''),'') FROM information_schema.views"

  # If ${SKIP_DATABASES} is not empty, create a where chain
  if [ ! -z "${SKIP_DATABASES}" ]; then
      VIEW_LIST_SQL="${VIEW_LIST_SQL} WHERE table_schema NOT IN ("
      # Split on ,
      SKIP_DATABASES=$(echo -e "${SKIP_DATABASES}" | tr "," "\n")
      for DB in ${SKIP_DATABASES} ; do
        VIEW_LIST_SQL="${VIEW_LIST_SQL}'${DB}'," ;
      done
      VIEW_LIST_SQL="${VIEW_LIST_SQL: : -1}"
      VIEW_LIST_SQL="${VIEW_LIST_SQL});"
  else
      VIEW_LIST_SQL=";"
  fi

  # Get result
  VIEWS_LIST=$(mysql ${MYSQL_CONN} -ANe"${VIEW_LIST_SQL}")

  if [ "$?" -ne 0 ]; then
    exitWithMsg 205 "Views listing failed"
  fi

  VIEW_IGNORE_ARG=()
  # Split on :!
  VIEWS=$(echo -e "${VIEWS_LIST}" | tr ":!" "\n")
  # echo -e "${VIEWS}"

  oldIFS=$IFS
  IFS=$'\n'
  for VIEW in $VIEWS; do # Concat ignore command
    # Replace ` in ${VIEW}, does not work with ` for --ignore-table
    VIEW="${VIEW//\`/}"
    #VIEW=$(printf '%q' "${VIEW}")
    VIEW_IGNORE_ARG+=(--ignore-table=${VIEW} )
  done
  IFS=$oldIFS
  # echo "${VIEW_IGNORE_ARG[@]}";
fi

hasSkip "structure"
if [ "$?" -eq 0 ]; then
  echo "Structure..."
  mysqldump ${MYSQLDUMP_DEFAULTS} --skip-add-drop-table --routines=FALSE --triggers=FALSE --events=FALSE --no-data "${VIEW_IGNORE_ARG[@]}" --databases ${DBS} > ${BACKUP_DIR}/structure.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 207 "Structure dump failed"
  fi
fi

hasSkip "data"
if [ "$?" -eq 0 ]; then
  echo "Data ..."
  mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=FALSE --events=FALSE --no-create-info "${VIEW_IGNORE_ARG[@]}" --databases ${DBS} > ${BACKUP_DIR}/database.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 208 "Data dump failed"
  fi
fi

hasSkip "routines"
if [ "$?" -eq 0 ]; then
  echo "Routines ..."
  mysqldump ${MYSQLDUMP_DEFAULTS} --routines=TRUE --triggers=FALSE --events=FALSE --no-create-info --no-data --no-create-db --databases ${DBS} > ${BACKUP_DIR}/routines.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 209 "Routines dump failed"
  fi
fi

hasSkip "triggers"
if [ "$?" -eq 0 ]; then
  echo "Triggers ..."
  mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=TRUE --events=FALSE --no-create-info --no-data --no-create-db --databases ${DBS} > ${BACKUP_DIR}/triggers.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 210 "Triggers dump failed"
  fi
fi

hasSkip "events"
  if [ "$?" -eq 0 ]; then
  echo "Events ..."
  mysqldump ${MYSQLDUMP_DEFAULTS} --routines=FALSE --triggers=FALSE --events=TRUE --no-create-info --no-data --no-create-db --databases ${DBS} > ${BACKUP_DIR}/events.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 211 "Events dump failed"
  fi
fi

hasSkip "views"
if [ "$?" -eq 0 ]; then
  echo "Views ..."
  VIEWS_SHOW_SQL=""
  oldIFS=$IFS
  IFS=$'\n'
  for VIEW in $VIEWS; do # Concat SHOW CREATE VIEW command
      VIEWS_SHOW_SQL="${VIEWS_SHOW_SQL}SHOW CREATE VIEW ${VIEW};"
  done
  IFS=$oldIFS

  # echo -e "${VIEWS_SHOW_SQL}"
  echo ${VIEWS_SHOW_SQL} | sed 's/;/\\G/g' | mysql ${MYSQL_CONN} > ${BACKUP_DIR}/views.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 212 "Views dump failed"
  fi

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
fi

hasSkip "users"
if [ "$?" -eq 0 ]; then
  echo "Users ..."
  mysqldump ${MYSQLDUMP_DEFAULTS} mysql --no-create-info --complete-insert --tables user db > ${BACKUP_DIR}/users.sql

  if [ "$?" -ne 0 ]; then
    exitWithMsg 213 "Users dump failed"
  fi
fi

hasSkip "grants"
if [ "$?" -eq 0 ]; then
  echo "Grants ..."
  # Needs refactor
  GRANTS_SQL="select distinct concat( \"SHOW GRANTS FOR '\",user,\"'@'\",host,\"';\" ) from mysql.user WHERE user != 'root';"
  GRANTS_LIST=$(mysql ${MYSQL_CONN} -ANe"${GRANTS_SQL}")
  if [ "$?" -ne 0 ]; then
    exitWithMsg 215 "Grants list failed"
  fi
  GRANTS_LIST=$(echo ${GRANTS_LIST} | mysql --default-character-set=utf8 --skip-comments ${MYSQL_CONN})
  if [ "$?" -ne 0 ]; then
    exitWithMsg 214 "Grants dump failed"
  fi
  printf "%s\n" "${GRANTS_LIST}" > ${BACKUP_DIR}/grants.sql
  # Replace headers to the SQL comment format
  sed -i -E "s/^Grants for (.*)/-- Grants for \1/" ${BACKUP_DIR}/grants.sql
  # Add a ; at each line end
  sed -i -E '/^-- Grants for/! s/^(.*)$/\1;/' ${BACKUP_DIR}/grants.sql

  # Removes double backslashes >  \\
  sed -i -e 's/\\\\//g' ${BACKUP_DIR}/grants.sql
fi


echo "Backup done !"

if [ ! -z "${ON_SUCCESS}" ]; then
  echo "$(${ON_SUCCESS})"
fi
exit 0