CREATE OR REPLACE PROCEDURE ds.fill_account_turnover_f(i_OnDate DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_BeginDate DATE;
    v_EndDate DATE;
BEGIN
    v_BeginDate := date_trunc('month', i_OnDate);
    v_EndDate := (date_trunc('month', i_OnDate) + INTERVAL '1 MONTH - 1 day')::DATE;

    DELETE FROM dm.dm_account_turnover_f
    WHERE on_date BETWEEN v_BeginDate AND v_EndDate;

    INSERT INTO dm.dm_account_turnover_f (
        on_date,
        account_rk,
        debet_amount,
        debet_amount_rub,
        credit_amount,
        credit_amount_rub
    )
    SELECT
        op.oper_date AS on_date,
        acc.account_rk,
        SUM(CASE WHEN op.debet_account_rk = acc.account_rk THEN op.debet_amount ELSE 0 END),
        SUM(CASE WHEN op.debet_account_rk = acc.account_rk THEN op.debet_amount * COALESCE(rate.reduced_cource, 1) ELSE 0 END),
        SUM(CASE WHEN op.credit_account_rk = acc.account_rk THEN op.credit_amount ELSE 0 END),
        SUM(CASE WHEN op.credit_account_rk = acc.account_rk THEN op.credit_amount * COALESCE(rate.reduced_cource, 1) ELSE 0 END)
    FROM
        ds.ft_posting_f op
    JOIN ds.md_account_d acc
        ON acc.account_rk IN (op.debet_account_rk, op.credit_account_rk)
       AND i_OnDate BETWEEN acc.data_actual_date AND acc.data_actual_end_date
    LEFT JOIN ds.md_exchange_rate_d rate
        ON rate.currency_rk = acc.currency_rk
       AND rate.data_actual_date = op.oper_date
    WHERE
        op.oper_date BETWEEN v_BeginDate AND v_EndDate
    GROUP BY
        acc.account_rk,
        op.oper_date;

    INSERT INTO logs.etl_proc_log (procedure_name, on_date, message)
    VALUES ('ds.fill_account_turnover_f', i_OnDate, 'Обороты успешно рассчитаны');
END;
$$;

