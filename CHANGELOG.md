# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2019-12-01
### Added
- Check if mysql and mysqldump are installed
- Updated README.md
- Added optional `BACKUP_CONFIG_ENVFILE` variable to set the env file location
- Updated .env-example (commented out some optional variables)
- Added check if `BACKUP_DIR` exists
- Added exit codes
- Added unit tests
- Updated .gitignore
- Bug fix (no views)
- Added option `SKIP_OP`
- Added option `MYSQL_PORT`
- Migrate from TravisCI to GitHub actions
- Some README improvements

## [1.0.0] - 2018-04-07
### Added
- CHANGELOG
- README
- LICENCE
- .env-example
- .gitignore
- backup.sh
