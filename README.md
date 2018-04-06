# sql-backup
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

## Options

| NAME           	| DEFAULT VALUE                                                                                                                  	| OPTIONAL 	|
|----------------	|--------------------------------------------------------------------------------------------------------------------------------	|----------	|
| BACKUP_DIR     	|                                                                                                                                	| NO       	|
| MYSQL_HOST     	|                                                                                                                                	| NO       	|
| MYSQL_USER     	|                                                                                                                                	| NO       	|
| MYSQL_PASS     	|                                                                                                                                	| YES      	|
| SKIP_DATABASES 	|                                                                                                                                	| YES      	|
| EXPERT_ARGS    	| --default-character-set=utf8 --extended-insert=FALSE --single-transaction --skip-comments --skip-dump-date --hex-blob --tz-utc 	| YES      	|

