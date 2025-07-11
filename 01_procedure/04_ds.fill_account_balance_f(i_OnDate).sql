CREATE OR REPLACE PROCEDURE ds.fill_account_balance_f(i_OnDate DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_PrevDate DATE;
BEGIN
    v_PrevDate := i_OnDate - INTERVAL '1 day';

    DELETE FROM dm.dm_account_balance_f
    WHERE on_date = i_OnDate;

    INSERT INTO dm.dm_account_balance_f (
        on_date,
        account_rk,
        balance_out,
        balance_out_rub
    )
    SELECT
        i_OnDate AS on_date,
        acc.account_rk,
        CASE acc.char_type
            WHEN 'А' THEN COALESCE(prev.balance_out, 0) + COALESCE(turn.debet_amount, 0) - COALESCE(turn.credit_amount, 0)
            WHEN 'П' THEN COALESCE(prev.balance_out, 0) - COALESCE(turn.debet_amount, 0) + COALESCE(turn.credit_amount, 0)
            ELSE 0
        END,
        CASE acc.char_type
            WHEN 'А' THEN COALESCE(prev.balance_out_rub, 0) + COALESCE(turn.debet_amount_rub, 0) - COALESCE(turn.credit_amount_rub, 0)
            WHEN 'П' THEN COALESCE(prev.balance_out_rub, 0) - COALESCE(turn.debet_amount_rub, 0) + COALESCE(turn.credit_amount_rub, 0)
            ELSE 0
        END
    FROM ds.md_account_d acc
    LEFT JOIN dm.dm_account_balance_f prev
        ON prev.account_rk = acc.account_rk AND prev.on_date = v_PrevDate
    LEFT JOIN dm.dm_account_turnover_f turn
        ON turn.account_rk = acc.account_rk AND turn.on_date = i_OnDate
    WHERE i_OnDate BETWEEN acc.data_actual_date AND acc.data_actual_end_date;

    INSERT INTO logs.etl_proc_log (procedure_name, on_date, message)
    VALUES ('ds.fill_account_balance_f', i_OnDate, 'Остатки успешно рассчитаны');
END;
$$;

