# sql-backup
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/8b72cd7316b745ed838b739cef3ebd38)](https://app.codacy.com/app/williamdes/sql-backup?utm_source=github.com&utm_medium=referral&utm_content=williamdes/sql-backup&utm_campaign=badger)
[![Build Status](https://travis-ci.org/williamdes/sql-backup.svg?branch=master)](https://travis-ci.org/williamdes/sql-backup)
[![codecov](https://codecov.io/gh/williamdes/sql-backup/branch/master/graph/badge.svg)](https://codecov.io/gh/williamdes/sql-backup)

Backup your MySQL server ( data, users, grants, views, triggers, routines, events )

## Install

```bash

git clone https://github.com/williamdes/sql-backup.git --depth 1
```
```bash
cd sql-backup

cp .env-example .env
```
```bash
nano .env
```
or  
```bash
vi .env

```
then  
```
./backup.sh
```
## Extras

To use an external env file in a custom location, example :
```bash

export BACKUP_CONFIG_ENVFILE="/home/myuser/secretbackupconfig.env.txt"

./backup.sh

unset BACKUP_CONFIG_ENVFILE
```   
You can use the variables of the env file in the `ON_SUCCESS` variable, example :   
```bash
ON_SUCCESS="${BACKUP_DIR}/onsuccessscript.sh"
```   


## Options

| NAME           	| DEFAULT VALUE                                                                                                                  	| OPTIONAL 	|
|----------------	|--------------------------------------------------------------------------------------------------------------------------------	|----------	|
| BACKUP_DIR     	|                                                                                                                                	| NO       	|
| MYSQL_HOST     	|                                                                                                                                	| NO       	|
| MYSQL_USER     	|                                                                                                                                	| NO       	|
| MYSQL_PASS     	|                                                                                                                                	| YES      	|
| SKIP_DATABASES 	|                                                                                                                                	| YES      	|
| EXPERT_ARGS    	| --default-character-set=utf8 --extended-insert=FALSE --single-transaction --skip-comments --skip-dump-date --hex-blob --tz-utc 	| YES      	|
| ON_SUCCESS     	|                                                                                                                                	| YES      	|

> ON_SUCCESS is called on script success

## Example .env

```bash
BACKUP_DIR=/sql_backup
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASS=root
SKIP_DATABASES=mysql,sys,information_schema,performance_schema,phpmyadmin
```

## Files

| NAME          	| DESCRIPTION                               	|
|---------------	|-------------------------------------------	|
| database.sql  	| All the data                              	|
| structure.sql 	| The structure of the databases and tables 	|
| grants.sql    	| The grants for all users except root      	|
| events.sql    	| The scheduled events                      	|
| views.sql     	| The views                                 	|
| triggers.sql  	| The triggers                              	|
| routines.sql  	| All the procedures & functions            	|
| users.sql     	| All MySQL users                           	|
