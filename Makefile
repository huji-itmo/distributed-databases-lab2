include .env


TPC_C_MIGRATIONS_DIR 	:= ./tpc-c/tpc-c-migrations
GOOSE_TABLE    			:= goose_migrations
GOOSE_DRIVER   			:= postgres
TPC_C_GOOSE_ENV			:= GOOSE_DRIVER=$(GOOSE_DRIVER) GOOSE_DBSTRING=${DB_DSN} GOOSE_MIGRATION_DIR=$(TPC_C_MIGRATIONS_DIR)

.PHONY: is_ready forward create_cluster

configure: is_ready apply_config

.PHONY: create_cluster
create_cluster: destroy_cluster
	bash scripts/create_cluster.sh
	sleep 2

apply_config:
	bash scripts/apply_config.sh

start:
	bash scripts/start_postgres.sh

stop:
	bash scripts/stop_postgres.sh

is_ready:
	bash scripts/is_ready.sh

destroy_cluster:
	rm -rf CLUSTER_FOLDER

sync:
	bash scripts/sync.sh

forward:
	ssh -L ${PORT}:localhost:${PORT} -N helios_pg

goose_init:
	${TPC_C_GOOSE_ENV} goose -table $(GOOSE_TABLE)} create initial sql

.PHONY: tpc-c-up
tpc-c-up:
	${TPC_C_GOOSE_ENV} goose -table $(GOOSE_TABLE) up

.PHONY: tpc-c-down
tpc-c-down:
	${TPC_C_GOOSE_ENV} goose -table $(GOOSE_TABLE) down

.PHONY: tpc-c-status
tpc-c-status:
	${TPC_C_GOOSE_ENV} goose -table $(GOOSE_TABLE) status

.PHONY: tpc-c-seed
tpc-c-seed: tpc-c-up
	  .venv/bin/python tpc-c/seed_tpc_c.py

.PHONY: tpc-c-clean-db
tpc-c-clean-db:
	  .venv/bin/python tpc-c/delete_all.py

.PHONY: disable-sync
disable-sync:
	bash scripts/disable_sync.sh

.PHONY: enable-sync
enable-sync:
	bash scripts/enable_sync.sh

.PHONY: tpc-c-bench
tpc-c-bench:
	pgbench -h 127.0.0.1 -U postgres4 -d postgres \
		-p 9213 \
		-l \
		-n \
        -f "tpc-c/tpc-c-new-order.sql" \
        -c 48 -j 48 -T 60 \
		-M prepared -P 5

.PHONY: tpc-c-bench-full
tpc-c-bench-full:
	pgbench -h localhost -U postgres4 -d postgres -p 9213 -n -c 48 -j 48 -T 60 -M prepared -P 5 \
		-f "tpc-c/tpc-c-new-order.sql@45" \
		-f "tpc-c/tpc-c-payment.sql@43" \
		-f "tpc-c/tpc-c-order-status.sql@4" \
		-f "tpc-c/tpc-c-delivery-transatction.sql@4" \
		-f "tpc-c/tpc-c-stock-level-transaction.sql@4"

.PHONY: tpc-b-seed
tpc-b-seed:
	psql -h localhost -U postgres4 -p 9213 -d postgres -f tpc-b/create_db.sql
	PGPASSWORD=${BENCH_PASSWORD} pgbench -h localhost -U bench_user -d benchmark_db -p 9213 \
	-i  -s 1

.PHONY: tpc-b-bench
tpc-b-bench:
	PGPASSWORD=${BENCH_PASSWORD} pgbench -h localhost -U bench_user -d benchmark_db -p 9213 \
	-c 100 -j 100 -T 60 \
	2>&1 | tail -20
