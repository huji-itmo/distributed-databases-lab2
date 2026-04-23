#!/usr/bin/env bash
source .env

rm -rf /var/db/postgres4/osz72
mkdir -p /var/db/postgres4/osz72

PGPASSWORD=${HUJI_PASSWORD} psql -h localhost -p 9213 \
    -U huji -d postgres  \
    -f task_3/task3_init.sql

# PGPASSWORD=${HUJI_PASSWORD} psql -h localhost -p 9213 \
#     -U huji -d postgres  \
#     -f task_3/task3_create_template1.sql

# PGPASSWORD="secure_password_123" psql -h localhost -p 9213 \
#     -U wetblue_user -d wetbluenews \
#     -f task_3/task3_init_wetbluenews.sql
