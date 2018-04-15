#!/bin/sh
# Error codes
# 200 = Empty Variable
# 201 = Value is not a file
# 202 = Value is not a directory
# 203 = Missing dependency
# 204 = A lising failed
# 205 = A dump failed

testEMPTY_VAR_Fail() {
  ./backup.sh 1>/dev/null 2>&1
  assertEquals 200 "$?"
}

testBACKUP_CONFIG_ENVFILE_Fail() {
  export BACKUP_CONFIG_ENVFILE="/home/myuser/secretbackupconfig.env.txt"
  ./backup.sh 1>/dev/null 2>&1
  assertEquals 201 "$?"
  unset BACKUP_CONFIG_ENVFILE
}

fillConfigFile() {
  echo "MYSQL_HOST=localhost" >> $1
  echo "MYSQL_USER=root" >> $1
  echo "MYSQL_PASS=testbench" >> $1
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
  ./backup.sh 1>/dev/null 2>&1
  assertEquals 204 "$?"
  unset BACKUP_CONFIG_ENVFILE
  postTest
}

testBACKUP_Success() {
  preTest
  export BACKUP_CONFIG_ENVFILE="./test/envfile"
  ./backup.sh 1>/dev/null 2>&1
  assertEquals 0 "$?"
  unset BACKUP_CONFIG_ENVFILE
  ls ./test/
  postTest
}

. ./shunit2-2.0.3/src/shell/shunit2