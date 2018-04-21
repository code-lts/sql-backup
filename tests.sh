#!/bin/sh
# Error codes
# 200 = Empty Variable
# 201 = Value is not a file
# 202 = Value is not a directory
# 203 = Missing dependency
# 204 = A lising failed
# 205 = A dump failed
# 206 = No databases to backup

MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASS="testbench"
SCRIPT_ROOT="$(dirname $0)"
echo "SCRIPT_ROOT=${SCRIPT_ROOT}"
MYSQLCREDS="-h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS}"

testEMPTY_VAR_Fail() {
  ./backup.sh 1>/dev/null 2>&1
  assertEquals 200 "$?"
}

compareFiles() {
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/structure.sql" "${SCRIPT_ROOT}/test/structure.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/database.sql" "${SCRIPT_ROOT}/test/database.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/grants.sql" "${SCRIPT_ROOT}/test/grants.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/users.sql" "${SCRIPT_ROOT}/test/users.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/events.sql" "${SCRIPT_ROOT}/test/events.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/views.sql" "${SCRIPT_ROOT}/test/views.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/triggers.sql" "${SCRIPT_ROOT}/test/triggers.sql"
  compareFilesOrExit "${SCRIPT_ROOT}/samples/$1/routines.sql" "${SCRIPT_ROOT}/test/routines.sql"
}

compareFilesSUM() {

  chk1="$(sha1sum $1 | awk -F" " '{print $1}')"
  chk2="$(sha1sum $2 | awk -F" " '{print $1}')"

  if [ "$chk1" = "$chk2" ]; then
    return 0
  else
    return 1
  fi

}

compareFilesOrExit() {
  diff -ia --unified=1 --suppress-common-lines "$1" "$2"
  compareFilesSUM "$@" || fail "Files are not identical ($1) ($2)"
}

testBACKUP_CONFIG_ENVFILE_Fail() {
  export BACKUP_CONFIG_ENVFILE="/home/myuser/secretbackupconfig.env.txt"
  ./backup.sh
  assertEquals 201 "$?"
  unset BACKUP_CONFIG_ENVFILE
}

fillConfigFile() {
  echo "MYSQL_HOST=${MYSQL_HOST}" >> $1
  echo "MYSQL_USER=${MYSQL_USER}" >> $1
  echo "MYSQL_PASS=${MYSQL_PASS}" >> $1
  echo "SKIP_DATABASES=mysql,sys,information_schema,performance_schema" >> $1
}

preTest() {
  mkdir ./test
  touch ./test/envfile
  echo "BACKUP_DIR=${SCRIPT_ROOT}/test" > ./test/envfile
  fillConfigFile ./test/envfile
  export BACKUP_CONFIG_ENVFILE="./test/envfile"
}

postTest() {
  rm ./test/*
  rmdir ./test
  unset BACKUP_CONFIG_ENVFILE
}

testBACKUP_CONFIG_ENVFILE_Success() {
  preTest
  echo "MYSQL_HOST=tests.test" >> "./test/envfile"
  ./backup.sh
  assertEquals 204 "$?"
  postTest
}

testBACKUP_EMPTY_Success() {
  preTest
  ./backup.sh
  assertEquals 206 "$?"
  postTest
}

testBACKUP_Success_NoDiff() {
  preTest
  mysql ${MYSQLCREDS} -e "CREATE DATABASE testbench CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  ./backup.sh
  assertEquals 0 "$?"
  mysql ${MYSQLCREDS} -e "DROP DATABASE testbench;"
  compareFiles "empty"
  postTest
}

testBACKUP_Success() {
  preTest
  mysql ${MYSQLCREDS} -e "CREATE DATABASE testbench CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  ./backup.sh
  assertEquals 0 "$?"
  mysql ${MYSQLCREDS} -e "DROP DATABASE testbench;"
  postTest
}

testOnSuccessScript() {
  preTest
  echo 'ON_SUCCESS="./postTest.sh"' >> "./test/envfile"
  mysql ${MYSQLCREDS} -e "CREATE DATABASE testbench CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  ./backup.sh
  cat ./test/endfile > /dev/null
  assertEquals 0 "$?"
  mysql ${MYSQLCREDS} -e "DROP DATABASE testbench;"
  postTest
}

testCompareFail() {
  # Expected fail
  compareFilesSUM "${SCRIPT_ROOT}/.gitignore" "${SCRIPT_ROOT}/samples/empty/events.sql"
  assertEquals 1 "$?"
}


testBACKUP_Success_NoDiff_Strange_BS_Data() {
  preTest
  mysql ${MYSQLCREDS} -e "CREATE DATABASE testbench CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  mysql ${MYSQLCREDS} -e 'USE testbench;CREATE TABLE `table hérétique ! @*:` (
    `ma première colonne` varchar(64) CHARACTER SET utf8mb4 NOT NULL,
    `qui utilise encore du latin sérieux` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=big5 COMMENT="Une table horrible";'
  mysql ${MYSQLCREDS} -e 'USE testbench;ALTER TABLE `table hérétique ! @*:` ADD PRIMARY KEY (`ma première colonne`);'
  mysql ${MYSQLCREDS} -e 'USE testbench;ALTER TABLE `table hérétique ! @*:` ADD INDEX(`qui utilise encore du latin sérieux`);'
  mysql ${MYSQLCREDS} -e 'USE testbench;ALTER TABLE `table hérétique ! @*:` ADD UNIQUE(`ma première colonne`);'
  mysql ${MYSQLCREDS} -e 'USE testbench;ALTER TABLE `table hérétique ! @*:` ADD KEY `les cons` (`qui utilise encore du latin sérieux`) USING BTREE;'
  ./backup.sh
  assertEquals 0 "$?"
  mysql ${MYSQLCREDS} -e "DROP DATABASE testbench;"
  compareFiles "withdata"
  postTest
}

testBACKUP_Success_NoDatabases() {
  preTest
  ./backup.sh
  assertEquals 206 "$?"
  postTest
}


. ./shunit2-2.1.7/shunit2
if [ ${__shunit_testsFailed} -eq 0 ]; then
  exit 0;
else
  exit 1;
fi