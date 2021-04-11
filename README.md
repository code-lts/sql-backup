# sql-backup - Backup your MySQL / MariaDB server !

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/1d6a522144ca4169a0c679bd9d299341)](https://www.codacy.com/gh/code-lts/sql-backup/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=code-lts/sql-backup&amp;utm_campaign=Badge_Grade)
[![Actions Status](https://github.com/code-lts/sql-backup/workflows/Run%20tests/badge.svg)](https://github.com/code-lts/sql-backup/actions)
[![codecov](https://codecov.io/gh/code-lts/sql-backup/branch/master/graph/badge.svg)](https://codecov.io/gh/code-lts/sql-backup)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fcode-lts%2Fsql-backup.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fcode-lts%2Fsql-backup?ref=badge_shield)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1827/badge)](https://bestpractices.coreinfrastructure.org/projects/1827)

Backup your MySQL / MariaDB server ( structure, data, users, grants, views, triggers, routines, events )

## Install

### Clone the repository

```sh
curl -L -# -o sql-backup.zip https://github.com/code-lts/sql-backup/archive/refs/tags/v1.2.0.zip
```

### Unzip file

```sh
unzip sql-backup.zip
```

### Move into the directory

```sh
cd sql-backup-1.2.0/
```

### Copy the configuration example

```sh
cp .env.dist .env
```

### Edit your configuration file

#### Nano

```sh
nano .env
```

#### Vi

```sh
vi .env
```

### Start backup

Execute this command to start the backup !

```sh
./backup.sh
```

## Extras

To use an external env file in a custom location, example :

```sh

export BACKUP_CONFIG_ENVFILE="/home/myuser/secretbackupconfig.env.txt"

./backup.sh

unset BACKUP_CONFIG_ENVFILE
```

You can use the variables of the env file in the `ON_SUCCESS` variable, example :

```sh
ON_SUCCESS="${BACKUP_DIR}/onsuccessscript.sh"
```

## Options

| NAME           | DEFAULT VALUE                                                                                                                  | OPTIONAL |
|----------------|--------------------------------------------------------------------------------------------------------------------------------|----------|
| BACKUP_DIR     |                                                                                                                                | NO       |
| MYSQL_HOST     |                                                                                                                                | NO       |
| MYSQL_USER     |                                                                                                                                | NO       |
| MYSQL_PASS     |                                                                                                                                | YES      |
| MYSQL_PORT     | 3306                                                                                                                           | YES      |
| SKIP_DATABASES |                                                                                                                                | YES      |
| EXPERT_ARGS    | --default-character-set=utf8 --extended-insert=FALSE --single-transaction --skip-comments --skip-dump-date --hex-blob --tz-utc | YES      |
| ON_SUCCESS     |                                                                                                                                | YES      |
| SKIP_OP        |                                                                                                                                | YES      |

> ON_SUCCESS is called on script success

## Example .env

```sh
BACKUP_DIR=/sql_backup
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASS=root
MYSQL_PORT=3306
SKIP_DATABASES=mysql,sys,information_schema,performance_schema,phpmyadmin
SKIP_OP=users,grants
```

## Files

| NAME          | DESCRIPTION                               |
|---------------|-------------------------------------------|
| database.sql  | All the data                              |
| structure.sql | The structure of the databases and tables |
| grants.sql    | The grants for all users except root      |
| events.sql    | The scheduled events                      |
| views.sql     | The views                                 |
| triggers.sql  | The triggers                              |
| routines.sql  | All the procedures & functions            |
| users.sql     | All MySQL users                           |

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fcode-lts%2Fsql-backup.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fcode-lts%2Fsql-backup?ref=badge_large)
