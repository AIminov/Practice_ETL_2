CREATE OR REPLACE PROCEDURE ds.fill_account_balance_f(i_OnDate date)
LANGUAGE plpgsql
AS $$
DECLARE
    v_RunId integer;
    v_CurrencyRate numeric := 1;
BEGIN
    -- Лог
    INSERT INTO logs.etl_audit(job_name, status)
    VALUES ('fill_account_balance_f', 'START')
    RETURNING run_id INTO v_RunId;

    -- Удаляем старые данные на дату
    DELETE FROM dm.dm_account_balance_f WHERE on_date = i_OnDate;

    -- Если дата = 2017-12-31, то грузим напрямую из ft_balance_f
    IF i_OnDate = DATE '2017-12-31' THEN
        --курс на дату
        SELECT reduced_cource
        INTO v_CurrencyRate
        FROM ds.md_exchange_rate_d
        WHERE data_actual_date = i_OnDate AND currency_rk = 643;

        IF NOT FOUND THEN
            v_CurrencyRate := 1;
        END IF;

        -- вставляем
        INSERT INTO dm.dm_account_balance_f (on_date, account_rk, balance_out, balance_out_rub)
        SELECT 
            i_OnDate, 
            account_rk, 
            balance_out, 
            balance_out * v_CurrencyRate
        FROM ds.ft_balance_f;
    END IF;

    -- Лог
    UPDATE logs.etl_audit
    SET status = 'END', finished_at = now(), rows_processed = (SELECT COUNT(*) FROM dm.dm_account_balance_f WHERE on_date = i_OnDate)
    WHERE run_id = v_RunId;

EXCEPTION WHEN OTHERS THEN
    -- Лог
    UPDATE logs.etl_audit
    SET status = 'ERROR', message = SQLERRM, finished_at = now()
    WHERE run_id = v_RunId;
    RAISE;
END;
$$;
