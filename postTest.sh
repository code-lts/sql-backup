#!/bin/bash

echo "$(date --utc --rfc-2822)" > "$(dirname $0)/test/endfile"
