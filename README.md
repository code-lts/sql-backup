# sql-backup
[![Maintainability](https://api.codeclimate.com/v1/badges/9af0b964df176436608d/maintainability)](https://codeclimate.com/github/williamdes/sql-backup/maintainability)

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
SKIP_DATABASES=mysql,information_schema,performance_schema,phpmyadmin
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
