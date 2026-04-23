CREATE OR REPLACE PROCEDURE insert_a_lot_of_test_data()
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1..10000 LOOP
        CALL insert_test_data();
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE insert_test_data()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO test_table (text)
    VALUES
        ('tung'),
        ('tung'),
        ('tung'),
        ('sahur');
END;
$$;
