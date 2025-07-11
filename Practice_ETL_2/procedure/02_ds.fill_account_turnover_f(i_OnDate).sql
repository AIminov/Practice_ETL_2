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

    -- Если дата = 2017-12-31 → загружаем стартовые остатки
    IF i_OnDate = DATE '2017-12-31' THEN
        SELECT reduced_cource
        INTO v_CurrencyRate
        FROM ds.md_exchange_rate_d
        WHERE data_actual_date = i_OnDate AND currency_rk = 643;

        IF NOT FOUND THEN
            v_CurrencyRate := 1;
        END IF;

        INSERT INTO dm.dm_account_balance_f (on_date, account_rk, balance_out, balance_out_rub)
        SELECT 
            i_OnDate, 
            account_rk, 
            balance_out, 
            balance_out * v_CurrencyRate
        FROM ds.ft_balance_f;
    ELSE
        -- Расчёт на основе остатков и оборотов
        INSERT INTO dm.dm_account_balance_f (
            on_date, account_rk, balance_out, balance_out_rub
        )
        SELECT
            i_OnDate,
            a.account_rk,
            CASE
                WHEN a.char_type = 'А' THEN COALESCE(b_prev.balance_out, 0) + COALESCE(t.debet_amount, 0) - COALESCE(t.credit_amount, 0)
                WHEN a.char_type = 'П' THEN COALESCE(b_prev.balance_out, 0) - COALESCE(t.debet_amount, 0) + COALESCE(t.credit_amount, 0)
                ELSE 0
            END AS balance_out,
            CASE
                WHEN a.char_type = 'А' THEN COALESCE(b_prev.balance_out_rub, 0) + COALESCE(t.debet_amount_rub, 0) - COALESCE(t.credit_amount_rub, 0)
                WHEN a.char_type = 'П' THEN COALESCE(b_prev.balance_out_rub, 0) - COALESCE(t.debet_amount_rub, 0) + COALESCE(t.credit_amount_rub, 0)
                ELSE 0
            END AS balance_out_rub
        FROM ds.md_account_d a
        LEFT JOIN dm.dm_account_balance_f b_prev
            ON a.account_rk = b_prev.account_rk AND b_prev.on_date = i_OnDate - INTERVAL '1 day'
        LEFT JOIN dm.dm_account_turnover_f t
            ON a.account_rk = t.account_rk AND t.on_date = i_OnDate
        WHERE i_OnDate BETWEEN a.data_actual_date AND COALESCE(a.data_actual_end_date, i_OnDate);

    END IF;

    -- Лог
    UPDATE logs.etl_audit
    SET status = 'END', finished_at = now(), rows_processed = (
        SELECT COUNT(*) FROM dm.dm_account_balance_f WHERE on_date = i_OnDate
    )
    WHERE run_id = v_RunId;

EXCEPTION WHEN OTHERS THEN
    UPDATE logs.etl_audit
    SET status = 'ERROR', message = SQLERRM, finished_at = now()
    WHERE run_id = v_RunId;
    RAISE;
END;
$$;
