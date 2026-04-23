include .env

configure: is_ready apply_config

.PHONY: create_cluster
create_cluster: destroy_cluster
	bash scripts/create_cluster.sh
	sleep 2

.PHONY: apply_config
apply_config:
	bash scripts/apply_config.sh

.PHONY: start
start:
	bash scripts/start_postgres.sh

.PHONY: stop
stop:
	bash scripts/stop_postgres.sh

.PHONY: is_ready
is_ready:
	bash scripts/is_ready.sh

.PHONY: destroy_cluster
destroy_cluster:
	rm -rf CLUSTER_FOLDER

.PHONY: sync
sync:
	bash scripts/sync.sh

.PHONY: sync_reserve
sync_reserve:
	bash scripts/sync_reserve.sh

.PHONY: sync_reserve2
sync_reserve2:
	bash scripts/sync_reserve2.sh

.PHONY: forward
forward:
	ssh -L ${PORT}:localhost:${PORT} -N helios_pg

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
