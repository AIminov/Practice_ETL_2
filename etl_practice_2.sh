#!/bin/bash

# скрипт выполнения 2 части практического задания

set -e  # Exit immediately on error

echo "[STEP 1a] создаем схему и таблицы"
psql -U postgres -d postgres -f ./00_ddl/00_create_dm_schema_tables.sql

echo "[STEP 1b] создаем таблицу логов для процедур"
psql -U postgres -d postgres -f ./00_ddl/01_create_proc_log_table.sql

echo "[STEP 2] создаем процедуры для загрузки баланса на 31.12.2017"
psql -U postgres -d postgres -f ./01_procedure/00_ds.fill_account_balance_f\('2017-12-31'\).sql

echo "[STEP 3] вызов процедуры"
psql -U postgres -d postgres -f ./01_procedure/01_ds.fill_account_balance_f\('2017-12-31'\)_CALL.sql

echo "[STEP 4] создаем процедуру для загрузки в turnover..."
psql -U postgres -d postgres -f ./01_procedure/02_ds.fill_account_turnover_f\(i_OnDate\).sql

echo "[STEP 5] вызываем процедуру для загрузки данных за 01.2018"
psql -U postgres -d postgres -f ./01_procedure/03_ds.fill_account_turnover_f\(i_OnDate\)_CALL.sql

echo "[STEP 6] создаем процедуру для расчета остатков..."
psql -U postgres -d postgres -f ./01_procedure/04_ds.fill_account_balance_f\(i_OnDate\).sql

echo "[STEP 7] вызываем процедуру расчета остатков за 01.2018"
psql -U postgres -d postgres -f ./01_procedure/05_ds.fill_account_balance_f_CALL.sql

echo "[DONE] выполнено"

