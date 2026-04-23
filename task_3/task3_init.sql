DROP DATABASE IF EXISTS wetbluenews;
DROP TABLESPACE IF EXISTS ts_osz72;

CREATE TABLESPACE ts_osz72 LOCATION '/var/db/postgres4/osz72';
CREATE DATABASE wetbluenews TEMPLATE template1 TABLESPACE ts_osz72;
CREATE ROLE wetblue_user WITH LOGIN PASSWORD 'secure_password_123';

GRANT CONNECT, CREATE ON DATABASE template1 TO wetblue_user;
GRANT CONNECT, CREATE ON DATABASE wetbluenews TO wetblue_user;
GRANT USAGE, CREATE ON SCHEMA public TO wetblue_user;

GRANT CREATE ON TABLESPACE ts_osz72 TO wetblue_user;

\c template1
GRANT ALL ON SCHEMA public TO wetblue_user;

\c wetbluenews
GRANT ALL ON SCHEMA public TO wetblue_user;

-- SELECT * FROM pg_tablespace;
