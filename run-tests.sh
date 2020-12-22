#!/bin/sh

set -e

apk add --update --no-cache mysql-client

./tests.sh
kcov --include-pattern=backup.sh,tests.sh --exclude-pattern=coverage $(pwd)/coverage ./tests.sh

ls -lahR ./coverage/
mv $(pwd)/coverage/tests.sh/cov.xml $(pwd)/coverage/cov.xml
