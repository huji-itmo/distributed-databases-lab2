#!/usr/bin/env bash
source .env

set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

mkdir -p physical-backup/${TIMESTAMP}/

pg_basebackup \
    -h "localhost" \
    -p 9213 \
    -D "physical-backup/${TIMESTAMP}/" \
    -Ft \
    -Xs \
    -P \
    -v

rsync physical-backup/${TIMESTAMP}/ -av --progress pg107:~/lab2/physical-backups/${TIMESTAMP}/
