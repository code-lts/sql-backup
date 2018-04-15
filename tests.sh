#!/bin/sh
# Error codes
# 200 = Empty Variable
# 201 = Value is not a file
# 202 = Value is not a directory
# 203 = Missing dependency
# 204 = A lising failed
# 205 = A dump failed
# 206 = No databases to backup

MYSQL_HOST="192.168.2.40"
MYSQL_USER="root"
MYSQL_PASS="testbench"
SCRIPT_ROOT=`dirname $0`
MYSQLCREDS="-h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS}"

testEMPTY_VAR_Fail() {
  ./backup.sh 1>/dev/null 2>&1
  assertEquals 200 "$?"
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
  echo "SKIP_DATABASES=mysql,information_schema,performance_schema" >> $1
}

preTest() {
  mkdir ./test
  touch ./test/envfile
  echo "BACKUP_DIR=`dirname $0`/test/" > ./test/envfile
  fillConfigFile ./test/envfile
}

postTest() {
  rm ./test/*
  rmdir ./test
}

testBACKUP_CONFIG_ENVFILE_Success() {
  preTest
  export BACKUP_CONFIG_ENVFILE="./test/envfile"
  echo "MYSQL_HOST=tests.test" >> "./test/envfile"
  ./backup.sh
  assertEquals 204 "$?"
  unset BACKUP_CONFIG_ENVFILE
  postTest
}

testBACKUP_EMPTY_Success() {
  preTest
  export BACKUP_CONFIG_ENVFILE="./test/envfile"
  ./backup.sh
  assertEquals 206 "$?"
  unset BACKUP_CONFIG_ENVFILE
  postTest
}

testBACKUP_Success() {
  preTest
  export BACKUP_CONFIG_ENVFILE="./test/envfile"
  mysql ${MYSQLCREDS} -e "CREATE DATABASE testbench CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  ./backup.sh
  assertEquals 0 "$?"
  mysql ${MYSQLCREDS} -e "DROP DATABASE testbench;"
  cmp --silent ${SCRIPT_ROOT}/samples/emptydatabase.sql ./test/structure.sql || fail "files are different"
  unset BACKUP_CONFIG_ENVFILE
  postTest
}

. ./shunit2-2.0.3/src/shell/shunit2
if [ ${__shunit_testsFailed} -eq 0 ]; then
  exit 0;
else
  exit 1;
fi