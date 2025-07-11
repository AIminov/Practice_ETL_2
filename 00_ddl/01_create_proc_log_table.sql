-- Создание схемы logs (если ещё не создана)
CREATE SCHEMA IF NOT EXISTS logs AUTHORIZATION postgres;

-- Таблица логирования для выполнения процедур
CREATE TABLE IF NOT EXISTS logs.etl_proc_log (
    proc_id BIGSERIAL PRIMARY KEY,
    procedure_name TEXT NOT NULL,
    log_dt TIMESTAMP DEFAULT clock_timestamp(),
    on_date DATE,
    message TEXT
);

