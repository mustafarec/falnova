-- Enable required extensions
DO $$
BEGIN
    -- uuid-ossp extension
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN
        CREATE EXTENSION "uuid-ossp" WITH SCHEMA public;
    END IF;

    -- pg_cron extension
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        CREATE EXTENSION pg_cron WITH SCHEMA cron;
    END IF;

    -- http extension
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'http') THEN
        DROP EXTENSION http CASCADE;
    END IF;
    CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA extensions;

    -- Grant necessary permissions
    GRANT USAGE ON SCHEMA cron TO postgres;
    GRANT ALL ON ALL TABLES IN SCHEMA cron TO postgres;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA cron TO postgres;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA cron TO postgres;
END
$$; 