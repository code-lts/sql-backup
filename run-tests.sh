#!/bin/sh

apk add --update --no-cache mysql-client

./tests.sh
kcov --include-pattern=backup.sh,tests.sh --exclude-pattern=coverage ./coverage ./tests.sh
