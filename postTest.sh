#!/bin/bash

echo "$(date --utc --rfc-email)" > "$(dirname $0)/test/endfile"
