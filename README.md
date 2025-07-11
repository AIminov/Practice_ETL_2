Этот проект реализует построение витрин DM.DM_ACCOUNT_TURNOVER_F и DM.DM_ACCOUNT_BALANCE_F на основе слоя DS. 
Данные загружены скриптом etl.py из репозитория Practice_ETL_1 и доступны в PostgreSQL в схеме DS.

Объяснение скриптов:

00_create_dm_schema_tables.sql
Создает схему dm
Создаёт 2 витрины: dm.dm_account_turnover_f и dm.dm_account_balance_f

00_ds.fill_account_balance_f('2017-12-31').sql
Создаёт процедуру ds.fill_account_balance_f(date)
По входной дате 2017-12-31 заполняет dm.dm_account_balance_f

01_ds.fill_account_balance_f('2017-12-31')_CALL.sql
Запуск процедуры для 2017-12-31

02_ds.fill_account_turnover_f(i_OnDate).sql
Создает процедуру расчёта оборотов dm.dm_account_turnover_f

03_ds.fill_account_turnover_f(i_OnDate)_CALL.sql
Циклом запускает ds.fill_account_turnover_f() с 2018-01-01 по 2018-01-31

04_ds.fill_account_balance_f_CALL.sql
Циклом расчитывает остатки за каждый день января 2018
