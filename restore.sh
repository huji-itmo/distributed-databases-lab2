#!/usr/bin/env bash

source .env

set -e

LAST_FILE=$(ls -1 backups/backup-*.dump | sort | tail -n 1)
echo "$LAST_FILE"

pg_restore -h localhost -U postgres3 -d postgres -p 9213 -F c $LAST_FILE
