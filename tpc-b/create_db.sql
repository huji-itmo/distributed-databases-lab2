CREATE DATABASE benchmark_db;
CREATE USER bench_user WITH PASSWORD 'benchmark-super-secure-password';

\c benchmark_db

GRANT CONNECT ON DATABASE benchmark_db TO bench_user;
GRANT CREATE ON SCHEMA public TO bench_user;
GRANT USAGE ON SCHEMA public TO bench_user;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO bench_user;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO bench_user;
