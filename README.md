Эта часть задачи реализует построение витрин DM.DM_ACCOUNT_TURNOVER_F и DM.DM_ACCOUNT_BALANCE_F на основе слоя DS.
Данные загружены скриптом etl.py из репозитория Practice_ETL_1.

Объяснение скриптов:

00_create_dm_schema_tables.sql
Создаёт схему dm
Создаёт 2 витрины: dm.dm_account_turnover_f и dm.dm_account_balance_f

01_create_proc_log_table.sql
Создаёт таблицу логов logs.etl_proc_log для хранения сообщений о выполнении процедур расчёта витрин

00_ds.fill_account_balance_f(2017-12-31).sql
Создаёт процедуру ds.fill_account_balance_f(date)
По входной дате 2017-12-31 заполняет dm.dm_account_balance_f остатками из ds.ft_balance_f

01_ds.fill_account_balance_f(2017-12-31)_CALL.sql
Запускает процедуру расчёта остатков за 2017-12-31

02_ds.fill_account_turnover_f(i_OnDate).sql
Создаёт процедуру ds.fill_account_turnover_f(date)
Рассчитывает обороты по каждому счёту за указанную дату и сохраняет в dm.dm_account_turnover_f

03_ds.fill_account_turnover_f(i_OnDate)_CALL.sql
Циклом запускает ds.fill_account_turnover_f() для всех дней января 2018 года

04_ds.fill_account_balance_f(i_OnDate).sql
Создаёт процедуру ds.fill_account_balance_f(date)
Рассчитывает остатки по каждому счёту на основе предыдущего дня и оборотов

05_ds.fill_account_balance_f_CALL.sql
Циклом запускает ds.fill_account_balance_f() для всех дней января 2018 года

etl_practice_2.sh
Сценарий запуска всех шагов по порядку — создание таблиц, запуск процедур, расчёт витрин и логирование

Логирование
Процедуры ds.fill_account_turnover_f и ds.fill_account_balance_f записывают информацию о выполнении в таблицу logs.etl_proc_log с полями: procedure_name, on_date, log_dt, message

Проверка
После запуска скрипта можно выполнить, например:

SELECT on_date, COUNT() FROM dm.dm_account_turnover_f GROUP BY on_date ORDER BY on_date;
SELECT on_date, COUNT() FROM dm.dm_account_balance_f GROUP BY on_date ORDER BY on_date;
SELECT * FROM logs.etl_proc_log ORDER BY log_dt DESC;
