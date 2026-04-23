CREATE ROLE huji WITH LOGIN PASSWORD 'secure_password_123' SUPERUSER;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO huji;
GRANT ALL PRIVILEGES ON DATABASE postgres TO huji;

--psql -h localhost -p 9213 -U postgres4 -d postgres -f create_user.sql
