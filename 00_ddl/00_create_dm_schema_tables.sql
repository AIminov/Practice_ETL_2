-- Создаём схему для витрин
CREATE SCHEMA IF NOT EXISTS dm AUTHORIZATION ds_owner;

-- витрина оборотов по счетам 
CREATE TABLE IF NOT EXISTS dm.dm_account_turnover_f (
    on_date            date           NOT NULL,
    account_rk         bigint         NOT NULL,
    credit_amount      numeric(20,2),
    credit_amount_rub  numeric(20,2),
    debet_amount       numeric(20,2),
    debet_amount_rub   numeric(20,2),
    CONSTRAINT pk_dm_account_turnover PRIMARY KEY (on_date, account_rk)
);

-- витрина остатков по счетам
CREATE TABLE IF NOT EXISTS dm.dm_account_balance_f (
    on_date            date           NOT NULL,
    account_rk         bigint         NOT NULL,
    balance_out        numeric(20,2),
    balance_out_rub    numeric(20,2),
    CONSTRAINT pk_dm_account_balance PRIMARY KEY (on_date, account_rk)
);
