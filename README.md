Григорьев Давид Владимирович
вариант 
Цель работы - настроить процедуру периодического резервного копирования базы данных, сконфигурированной в ходе выполнения лабораторной работы №2, а также разработать и отладить сценарии восстановления в случае сбоев.

Узел из предыдущей лабораторной работы используется в качестве основного. Новый узел используется в качестве резервного. Учётные данные для подключения к новому узлу выдаёт преподаватель. В сценариях восстановления необходимо использовать копию данных, полученную на первом этапе данной лабораторной работы.

## Этап 1. Резервное копирование

Настроить резервное копирование с основного узла на резервный следующим образом:

* Периодические полные копии с помощью SQL Dump.
* По расписанию (cron) раз в сутки, методом SQL Dump с сжатием. Созданные архивы должны сразу перемещаться на резервный хост, они не должны храниться на основной системе. Срок хранения архивов на резервной системе - 4 недели. По истечении срока хранения, старые архивы должны автоматически уничтожаться.
* Подсчитать, каков будет объем резервных копий спустя месяц работы системы, исходя из следующих условий:

  *  Средний объем новых данных в БД за сутки: 750МБ.
  *  Средний объем измененных данных за сутки: 800МБ.


## Этап 2. Конфигурация и запуск сервера БД

*   Способы подключения: 1) Unix-domain сокет в режиме peer; 2) сокет TCP/IP, принимать подключения к любому IP-адресу узла
*   Номер порта: `9458`
*   Способ аутентификации TCP/IP клиентов: по паролю в открытом виде
*   Остальные способы подключений запретить.
*   Настроить следующие параметры сервера БД:
    *   max_connections
    *   shared_buffers
    *   temp_buffers
    *   work_mem
    *   checkpoint_timeout
    *   effective_cache_size
    *   fsync
    *   commit_delay

Параметры должны быть подобраны в соответствии со сценарием OLTP: 1500 транзакций в секунду размером 8КБ; обеспечить высокую доступность (High Availability) данных.

*   Директория WAL файлов: `$PGDATA/pg_wal`
*   Формат лог-файлов: `.log`
*   Уровень сообщений лога: `NOTICE`
*   Дополнительно логировать: попытки подключения и завершение сессий

## Задание 1:

Создание кластера:

```bash
#!/usr/bin/env bash
source .env

rm -rf $CLUSTER_FOLDER

mkdir -p $CLUSTER_FOLDER

initdb \
    -D $CLUSTER_FOLDER \
    --locale ru_RU.UTF-8 \
    -c port=$PORT
    # --encoding=WIN1251 \
```

Запуск постгреса:

```bash
#!/usr/bin/env bash
source .env

pg_ctl -D $CLUSTER_FOLDER start
```

чтобы использовать переменные окружения 

```bash
cp .env-example .env
```
```bash
set -o allexport;
source .env;
set +o allexport;
```

hba file
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD


local   all             postgres                                peer
# local   all             all                                     peer
host    all             all             ::/0                    password
host    all             all             0.0.0.0/0               password

local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
```
hba_file=/var/db/postgres4/lab2/pg_hba.conf

## Задание 2:

Оптимизация:
1. перенести pgbench на сервер, чтобы понизить latency (+~700)
2. поднять количество пользователей, потоков на максимальные (+~300)
3. понизить temp_mem, workmem чтобы позволить поднять количество пользователей с 50 до 150 (+~200)

Результат:
```
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 10
query mode: simple
number of clients: 200
number of threads: 200
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 73374
number of failed transactions: 0 (0.000%)
latency average = 165.324 ms
initial connection time = 100.392 ms
tps = 1209.744911 (without initial connection time)
```

параметры

```
max_connections=350
shared_buffers=60MB
temp_buffers=1MB
work_mem=1MB
wal_buffers=4MB
checkpoint_timeout=15min
effective_cache_size=512MB
fsync=off
commit_delay=10000
effective_io_concurrency=200
random_page_cost=1.1
synchronous_commit=off
ssl=off
hba_file=/var/db/postgres4/lab2/pg_hba.conf
```

Для применения параметров:

host machine:
```
make sync
```

guest ssh:
```
pg_ctl start
make configure
pg_ctl restart
```

Для запуска бенчмарка:

```
make tpc-b-bench
```

## Задание 3:

Создание tablespace, и бд

```sql
CREATE TABLESPACE ts_osz72 LOCATION '/var/db/postgres4/osz72';
ALTER DATABASE template1 SET TABLESPACE ts_osz72;
CREATE DATABASE wetbluenews TEMPLATE template1;
CREATE ROLE wetblue_user WITH LOGIN PASSWORD 'secure_password_123';

GRANT CONNECT, CREATE ON DATABASE template1 TO wetblue_user;
GRANT CONNECT, CREATE ON DATABASE wetbluenews TO wetblue_user;

GRANT CREATE ON TABLESPACE ts_osz72 TO wetblue_user;

\c template1
GRANT ALL ON SCHEMA public TO wetblue_user;

\c wetbluenews
GRANT ALL ON SCHEMA public TO wetblue_user;

-- SELECT * FROM pg_tablespace;

```

Заполнение тестовой БД тестовыми данными

```sql
CREATE TABLE news_articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    content TEXT
) TABLESPACE ts_osz72;

CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    action VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
) TABLESPACE ts_osz72;

INSERT INTO news_articles (title, content) VALUES
('Заголовок 1', 'Текст новости 1'),
('Заголовок 2', 'Текст новости 2');

INSERT INTO user_logs (action) VALUES
('Login'),
('Create Article'),
('Logout');
```


Заполнение template1 (пример)

```sql
\c template1

CREATE TABLE template_test_data (
    id SERIAL PRIMARY KEY,
    description TEXT
) TABLESPACE ts_osz72;

INSERT INTO template_test_data (description) VALUES ('Данные в новом tablespace');

```

если создать новую бд, эти таблицы будут по умолчанию
