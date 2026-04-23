\c template1

CREATE TABLE template_test_data (
    id SERIAL PRIMARY KEY,
    description TEXT
) TABLESPACE ts_osz72;

INSERT INTO template_test_data (description) VALUES ('Данные в новом ТС');
