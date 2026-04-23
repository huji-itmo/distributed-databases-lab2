#!/usr/bin/env bash
source .env

set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

FILENAME=backup-${TIMESTAMP}.dump

mkdir -p backup/

pg_dump -U ${VM_USERNAME} -d ${DBNAME} -p 9213 -F c -f backup/${FILENAME}

rsync backup/${FILENAME} -av --progress pg104:~/lab2/backups/${FILENAME}
