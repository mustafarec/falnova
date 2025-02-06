-- pg_cron extension'ını etkinleştir
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- cron şemasına erişim izni ver
GRANT USAGE ON SCHEMA cron TO postgres;

-- cron tablosuna erişim izni ver
GRANT ALL ON ALL TABLES IN SCHEMA cron TO postgres; 