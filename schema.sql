

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."check_scheduled_notifications"("input_user_id" "uuid", "is_test" boolean DEFAULT false) RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
    notification_count integer;
    result json;
    notification_record record;
    fcm_token text;
    edge_function_response json;
    service_role_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybnJ1c3hicHZhemxwdWlmaGpwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjA3NjQ3MSwiZXhwIjoyMDUxNjUyNDcxfQ.kF-REQVy3AuJC8IYQbMkAw8xTpYBzKmR0cYdzaAwa6g';
begin
    -- FCM token'ı al
    SELECT token INTO fcm_token 
    FROM fcm_tokens 
    WHERE user_id = input_user_id 
    ORDER BY created_at DESC 
    LIMIT 1;

    -- Normal mod için işlemler (zamanlanmış bildirimleri kontrol et)
    FOR notification_record IN 
        SELECT n.* 
        FROM notifications n
        WHERE n.user_id = input_user_id
        AND NOT n.is_sent
        AND n.scheduled_time <= now()
    LOOP
        -- FCM bildirimi gönder
        IF fcm_token IS NOT NULL THEN
            SELECT content::json INTO edge_function_response
            FROM http_post(
                'https://mrnrusxbpvazlpuifhjp.supabase.co/functions/v1/send-fcm',
                json_build_object(
                    'token', fcm_token,
                    'title', notification_record.title,
                    'body', notification_record.body,
                    'data', json_build_object(
                        'notification_id', notification_record.id::text,
                        'type', notification_record.type
                    )
                )::text,
                ARRAY[
                    ('Authorization', 'Bearer ' || service_role_key)::http_header,
                    ('Content-Type', 'application/json')::http_header
                ]::http_header[]
            );

            -- Bildirimi gönderildi olarak işaretle
            IF (edge_function_response->>'name') IS NOT NULL THEN
                UPDATE notifications
                SET is_sent = true,
                    updated_at = now()
                WHERE id = notification_record.id;
            END IF;
        END IF;
    END LOOP;

    GET DIAGNOSTICS notification_count = ROW_COUNT;
    
    result := json_build_object(
        'success', true,
        'message', format('%s notifications processed', notification_count),
        'count', notification_count,
        'last_response', edge_function_response
    );
    
    return result;
end;
$$;


ALTER FUNCTION "public"."check_scheduled_notifications"("input_user_id" "uuid", "is_test" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_notification"("p_user_id" "uuid", "p_notification_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    DELETE FROM notifications
    WHERE id = p_notification_id
    AND user_id = p_user_id;

    RETURN FOUND;
END;
$$;


ALTER FUNCTION "public"."delete_notification"("p_user_id" "uuid", "p_notification_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."format_headers"("headers" "public"."http_header"[]) RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    result text[];
BEGIN
    SELECT array_agg(header.k || ': ' || header.v)
    INTO result
    FROM unnest(headers) AS header(k, v);
    
    RETURN COALESCE(result, ARRAY[]::text[]);
END;
$$;


ALTER FUNCTION "public"."format_headers"("headers" "public"."http_header"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_latest_notifications"("p_user_id" "uuid", "p_type" "text" DEFAULT NULL::"text", "p_limit" integer DEFAULT 10) RETURNS TABLE("id" "uuid", "type" "text", "title" "text", "body" "text", "data" "jsonb", "read" boolean, "scheduled_for" timestamp with time zone, "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.id,
        n.type,
        n.title,
        n.body,
        n.data,
        n.read,
        n.scheduled_for,
        n.created_at
    FROM notifications n
    WHERE n.user_id = p_user_id
    AND (p_type IS NULL OR n.type = p_type)
    ORDER BY n.created_at DESC
    LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."get_latest_notifications"("p_user_id" "uuid", "p_type" "text", "p_limit" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INTEGER
        FROM notifications
        WHERE user_id = p_user_id
        AND read = false
    );
END;
$$;


ALTER FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_fortune_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    INSERT INTO fortune_notifications (user_id, fortune_id, title, message)
    VALUES (
      NEW.user_id,
      NEW.uuid,
      'Falınız Hazır! 🔮',
      'Kahve falınız yorumlandı. Hemen görmek için tıklayın.'
    );
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_fortune_status_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, first_name, last_name, birth_date)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    (NEW.raw_user_meta_data->>'birth_date')::date
  );

  -- Create notification settings with defaults
  INSERT INTO public.notification_settings (user_id)
  VALUES (NEW.id);

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."http_post"("post_url" "text", "post_body" "text", "post_headers" "public"."http_header"[] DEFAULT '{}'::"public"."http_header"[]) RETURNS TABLE("status" integer, "content" "text", "headers" "text"[])
    LANGUAGE "plpgsql"
    AS $$
begin
    return query
    select * from http_request('POST', post_url, post_headers::text[], post_body);
end;
$$;


ALTER FUNCTION "public"."http_post"("post_url" "text", "post_body" "text", "post_headers" "public"."http_header"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."http_request"("http_method" "text", "http_url" "text", "http_headers" "text"[] DEFAULT '{}'::"text"[], "http_body" "text" DEFAULT ''::"text") RETURNS TABLE("status" integer, "content" "text", "headers" "text"[])
    LANGUAGE "plpgsql"
    AS $$
declare
    _request http_request;
begin
    _request := (
        http_method::http_method,  -- method artık http_method tipinde
        http_url::varchar,         -- uri varchar tipinde
        http_headers::http_header[],
        'application/json'::varchar,  -- content_type
        http_body::varchar           -- content
    )::http_request;
    
    return query
    select 
        response.status::int,
        response.content::text,
        response.headers::text[]
    from http(_request) as response;
end;
$$;


ALTER FUNCTION "public"."http_request"("http_method" "text", "http_url" "text", "http_headers" "text"[], "http_body" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_all_notifications_as_read"("p_user_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    WITH updated AS (
        UPDATE notifications
        SET read = true
        WHERE user_id = p_user_id
        AND read = false
        RETURNING id
    )
    SELECT COUNT(*) INTO updated_count FROM updated;

    RETURN updated_count;
END;
$$;


ALTER FUNCTION "public"."mark_all_notifications_as_read"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."schedule_coffee_fortune_notifications"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    settings RECORD;
    reminder_time TEXT;
    scheduled_time TIMESTAMP WITH TIME ZONE;
BEGIN
    FOR settings IN 
        SELECT 
            ns.user_id,
            unnest(ns.coffee_reminder_time) as reminder_time
        FROM notification_settings ns
        WHERE ns.coffee_reminder_enabled = true
    LOOP
        -- Calculate next scheduled time
        scheduled_time := (CURRENT_DATE + reminder_time::TIME)::TIMESTAMP WITH TIME ZONE;
        
        -- If time has passed today, schedule for tomorrow
        IF scheduled_time <= CURRENT_TIMESTAMP THEN
            scheduled_time := scheduled_time + INTERVAL '1 day';
        END IF;

        -- Only create if no notification exists for this time
        IF NOT EXISTS (
            SELECT 1 
            FROM notifications 
            WHERE user_id = settings.user_id 
            AND type = 'coffee_fortune'
            AND scheduled_for = scheduled_time
        ) THEN
            -- Schedule the notification
            PERFORM send_notification(
                settings.user_id,
                'coffee_fortune',
                'Kahve Falı Zamanı ☕',
                'Fincanınızı hazırlayın, size özel kahve falı için hazırız!',
                NULL,
                scheduled_time
            );
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."schedule_coffee_fortune_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."schedule_horoscope_notifications"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    settings RECORD;
    scheduled_time TIMESTAMP WITH TIME ZONE;
BEGIN
    FOR settings IN 
        SELECT 
            ns.user_id,
            ns.horoscope_reminder_time,
            p.birth_date
        FROM notification_settings ns
        JOIN profiles p ON p.id = ns.user_id
        WHERE ns.horoscope_reminder_enabled = true
    LOOP
        -- Calculate next scheduled time
        scheduled_time := (CURRENT_DATE + settings.horoscope_reminder_time::TIME)::TIMESTAMP WITH TIME ZONE;
        
        -- If time has passed today, schedule for tomorrow
        IF scheduled_time <= CURRENT_TIMESTAMP THEN
            scheduled_time := scheduled_time + INTERVAL '1 day';
        END IF;

        -- Only create if no notification exists for this time
        IF NOT EXISTS (
            SELECT 1 
            FROM notifications 
            WHERE user_id = settings.user_id 
            AND type = 'horoscope'
            AND scheduled_for = scheduled_time
        ) THEN
            -- Schedule the notification
            PERFORM send_notification(
                settings.user_id,
                'horoscope',
                'Günlük Burcunuz Hazır! 🌟',
                'Bugün sizin için neler olacağını öğrenmek için tıklayın.',
                jsonb_build_object('birth_date', settings.birth_date),
                scheduled_time
            );
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."schedule_horoscope_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_notification"("p_user_id" "uuid", "p_type" "text", "p_title" "text", "p_body" "text", "p_data" "jsonb" DEFAULT NULL::"jsonb", "p_scheduled_for" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    -- Insert the notification
    INSERT INTO notifications (
        user_id,
        type,
        title,
        body,
        data,
        scheduled_for
    )
    VALUES (
        p_user_id,
        p_type,
        p_title,
        p_body,
        p_data,
        p_scheduled_for
    )
    RETURNING id INTO v_notification_id;

    RETURN v_notification_id;
END;
$$;


ALTER FUNCTION "public"."send_notification"("p_user_id" "uuid", "p_type" "text", "p_title" "text", "p_body" "text", "p_data" "jsonb", "p_scheduled_for" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_notification_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Eğer scheduled_time geldi ve bildirim gönderilmediyse
    IF NEW.scheduled_time <= NOW() AND NOT NEW.is_sent THEN
        -- HTTP isteği gönder
        PERFORM http_post(
            'https://mrnrusxbpvazlpuifhjp.supabase.co/functions/v1/send-fcm',
            json_build_object(
                'token', (SELECT token FROM fcm_tokens WHERE user_id = NEW.user_id ORDER BY created_at DESC LIMIT 1),
                'title', NEW.title,
                'body', NEW.body,
                'data', json_build_object(
                    'notification_id', NEW.id::text,
                    'type', NEW.type
                )
            )::text,
            ARRAY[
                ('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybnJ1c3hicHZhemxwdWlmaGpwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjA3NjQ3MSwiZXhwIjoyMDUxNjUyNDcxfQ.kF-REQVy3AuJC8IYQbMkAw8xTpYBzKmR0cYdzaAwa6g')::http_header,
                ('Content-Type', 'application/json')::http_header
            ]::http_header[]
        );
        
        -- Bildirimi gönderildi olarak işaretle
        NEW.is_sent := true;
        NEW.updated_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."send_notification_trigger"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_push_notification"("p_token" "text", "p_title" "text", "p_body" "text", "p_type" "text", "p_notification_id" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_response json;
BEGIN
    SELECT content::json INTO v_response
    FROM http_post(
        'https://mrnrusxbpvazlpuifhjp.supabase.co/functions/v1/send-fcm',
        json_build_object(
            'token', p_token,
            'title', p_title,
            'body', p_body,
            'data', json_build_object(
                'notification_id', COALESCE(p_notification_id::text, ''),
                'type', p_type
            )
        )::text,
        ARRAY[
            ('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybnJ1c3hicHZhemxwdWlmaGpwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjA3NjQ3MSwiZXhwIjoyMDUxNjUyNDcxfQ.kF-REQVy3AuJC8IYQbMkAw8xTpYBzKmR0cYdzaAwa6g')::http_header,
            ('Content-Type', 'application/json')::http_header
        ]::http_header[]
    );
    
    RETURN v_response;
END;
$$;


ALTER FUNCTION "public"."send_push_notification"("p_token" "text", "p_title" "text", "p_body" "text", "p_type" "text", "p_notification_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean DEFAULT false) RETURNS TABLE("status" integer, "content" "text", "headers" "text"[])
    LANGUAGE "plpgsql"
    AS $$
declare
    project_ref text := 'falnova';
    anon_key text := current_setting('request.headers')::json->>'apikey';  -- Supabase anon key'i alalım
begin
    return query
    select *
    from http_post(
        'https://' || project_ref || '.supabase.co/rest/v1/rpc/check_scheduled_notifications',  -- URL'yi rest/v1/rpc formatında değiştirdik
        json_build_object(
            'user_id', test_user_id,
            'is_test', is_test
        )::text,
        ARRAY[
            ('apikey', anon_key)::http_header,
            ('Authorization', 'Bearer ' || anon_key)::http_header,
            ('Content-Type', 'application/json')::http_header,
            ('Prefer', 'return=minimal')::http_header
        ]::http_header[]
    );
end;
$$;


ALTER FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean DEFAULT false, "api_key" "text" DEFAULT NULL::"text") RETURNS TABLE("status" integer, "content" "text", "headers" "text"[])
    LANGUAGE "plpgsql"
    AS $$
declare
    project_ref text := 'mrnrusxbpvazlpuifhjp';
begin
    -- API key boşsa hata verelim
    if api_key is null then
        raise exception 'API key is required';
    end if;

    return query
    select *
    from http_post(
        'https://' || project_ref || '.supabase.co/rest/v1/rpc/check_scheduled_notifications',
        json_build_object(
            'input_user_id', test_user_id,  -- parametre adını değiştirdik
            'is_test', is_test
        )::text,
        ARRAY[
            ('apikey', api_key)::http_header,
            ('Authorization', 'Bearer ' || api_key)::http_header,
            ('Content-Type', 'application/json')::http_header,
            ('Prefer', 'return=minimal')::http_header
        ]::http_header[]
    );
end;
$$;


ALTER FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean, "api_key" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_last_sign_in"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.last_sign_in = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_last_sign_in"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_notification_preferences"("p_user_id" "uuid", "p_horoscope_enabled" boolean DEFAULT NULL::boolean, "p_coffee_enabled" boolean DEFAULT NULL::boolean, "p_horoscope_time" "text" DEFAULT NULL::"text", "p_coffee_times" "text"[] DEFAULT NULL::"text"[]) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE notification_settings
    SET
        horoscope_reminder_enabled = COALESCE(p_horoscope_enabled, horoscope_reminder_enabled),
        coffee_reminder_enabled = COALESCE(p_coffee_enabled, coffee_reminder_enabled),
        horoscope_reminder_time = COALESCE(p_horoscope_time, horoscope_reminder_time),
        coffee_reminder_time = COALESCE(p_coffee_times, coffee_reminder_time),
        updated_at = NOW()
    WHERE user_id = p_user_id;

    -- Eğer güncelleme başarılıysa true döner
    RETURN FOUND;
END;
$$;


ALTER FUNCTION "public"."update_notification_preferences"("p_user_id" "uuid", "p_horoscope_enabled" boolean, "p_coffee_enabled" boolean, "p_horoscope_time" "text", "p_coffee_times" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."fcm_tokens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "device_info" "jsonb",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."fcm_tokens" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."fortune_readings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "image_url" "text",
    "interpretation" "text" NOT NULL,
    "is_premium" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."fortune_readings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."horoscopes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sign" "text" NOT NULL,
    "date" "date" NOT NULL,
    "daily_horoscope" "text" NOT NULL,
    "love_score" integer,
    "career_score" integer,
    "health_score" integer,
    "luck_score" integer,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "horoscopes_career_score_check" CHECK ((("career_score" >= 0) AND ("career_score" <= 100))),
    CONSTRAINT "horoscopes_health_score_check" CHECK ((("health_score" >= 0) AND ("health_score" <= 100))),
    CONSTRAINT "horoscopes_love_score_check" CHECK ((("love_score" >= 0) AND ("love_score" <= 100))),
    CONSTRAINT "horoscopes_luck_score_check" CHECK ((("luck_score" >= 0) AND ("luck_score" <= 100)))
);


ALTER TABLE "public"."horoscopes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notification_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "horoscope_reminder_enabled" boolean DEFAULT true,
    "coffee_reminder_enabled" boolean DEFAULT true,
    "horoscope_reminder_time" "text" DEFAULT '09:00'::"text",
    "coffee_reminder_time" "text"[] DEFAULT ARRAY['09:00'::"text"],
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."notification_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "data" "jsonb",
    "read" boolean DEFAULT false,
    "scheduled_for" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "is_read" boolean DEFAULT false,
    "scheduled_time" timestamp with time zone,
    "is_sent" boolean DEFAULT false
);

ALTER TABLE ONLY "public"."notifications" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "birth_date" "date",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_user_id_token_key" UNIQUE ("user_id", "token");



ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_user_id_unique" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."fortune_readings"
    ADD CONSTRAINT "fortune_readings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."horoscopes"
    ADD CONSTRAINT "horoscopes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."horoscopes"
    ADD CONSTRAINT "horoscopes_sign_date_key" UNIQUE ("sign", "date");



ALTER TABLE ONLY "public"."notification_settings"
    ADD CONSTRAINT "notification_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notification_settings"
    ADD CONSTRAINT "notification_settings_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_fcm_tokens_user_id" ON "public"."fcm_tokens" USING "btree" ("user_id");



CREATE INDEX "idx_notifications_scheduled_time" ON "public"."notifications" USING "btree" ("scheduled_time");



CREATE INDEX "idx_notifications_user_id_is_read" ON "public"."notifications" USING "btree" ("user_id", "is_read");



CREATE INDEX "idx_notifications_user_id_type" ON "public"."notifications" USING "btree" ("user_id", "type");



CREATE OR REPLACE TRIGGER "update_fcm_tokens_updated_at" BEFORE UPDATE ON "public"."fcm_tokens" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_fortune_readings_updated_at" BEFORE UPDATE ON "public"."fortune_readings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_horoscopes_updated_at" BEFORE UPDATE ON "public"."horoscopes" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_notification_settings_updated_at" BEFORE UPDATE ON "public"."notification_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_notifications_updated_at" BEFORE UPDATE ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."fortune_readings"
    ADD CONSTRAINT "fortune_readings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."notification_settings"
    ADD CONSTRAINT "notification_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



CREATE POLICY "Everyone can view horoscopes" ON "public"."horoscopes" FOR SELECT USING (true);



CREATE POLICY "Users can delete their own FCM tokens" ON "public"."fcm_tokens" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own notifications" ON "public"."notifications" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own FCM tokens" ON "public"."fcm_tokens" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own fortune readings" ON "public"."fortune_readings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own notification settings" ON "public"."notification_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own notifications" ON "public"."notifications" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can read their own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own FCM tokens" ON "public"."fcm_tokens" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own notification settings" ON "public"."notification_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own notifications" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view their own FCM tokens" ON "public"."fcm_tokens" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own fortune readings" ON "public"."fortune_readings" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own notification settings" ON "public"."notification_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "id"));



ALTER TABLE "public"."fcm_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."fortune_readings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."horoscopes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notification_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE PUBLICATION "realtime_messages_publication_v2_34_0" WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION "realtime_messages_publication_v2_34_0" OWNER TO "supabase_admin";




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;




















































































































































































GRANT ALL ON FUNCTION "public"."bytea_to_text"("data" "bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."bytea_to_text"("data" "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."bytea_to_text"("data" "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bytea_to_text"("data" "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_scheduled_notifications"("input_user_id" "uuid", "is_test" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."check_scheduled_notifications"("input_user_id" "uuid", "is_test" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_scheduled_notifications"("input_user_id" "uuid", "is_test" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_notification"("p_user_id" "uuid", "p_notification_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_notification"("p_user_id" "uuid", "p_notification_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_notification"("p_user_id" "uuid", "p_notification_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."format_headers"("headers" "public"."http_header"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."format_headers"("headers" "public"."http_header"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."format_headers"("headers" "public"."http_header"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_latest_notifications"("p_user_id" "uuid", "p_type" "text", "p_limit" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_latest_notifications"("p_user_id" "uuid", "p_type" "text", "p_limit" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_latest_notifications"("p_user_id" "uuid", "p_type" "text", "p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_fortune_status_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_fortune_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_fortune_status_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."http"("request" "public"."http_request") TO "postgres";
GRANT ALL ON FUNCTION "public"."http"("request" "public"."http_request") TO "anon";
GRANT ALL ON FUNCTION "public"."http"("request" "public"."http_request") TO "authenticated";
GRANT ALL ON FUNCTION "public"."http"("request" "public"."http_request") TO "service_role";



GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying, "content" character varying, "content_type" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying, "content" character varying, "content_type" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying, "content" character varying, "content_type" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_delete"("uri" character varying, "content" character varying, "content_type" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying, "data" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying, "data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying, "data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_get"("uri" character varying, "data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."http_head"("uri" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_head"("uri" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_head"("uri" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_head"("uri" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_header"("field" character varying, "value" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_header"("field" character varying, "value" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_header"("field" character varying, "value" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_header"("field" character varying, "value" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_list_curlopt"() TO "postgres";
GRANT ALL ON FUNCTION "public"."http_list_curlopt"() TO "anon";
GRANT ALL ON FUNCTION "public"."http_list_curlopt"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_list_curlopt"() TO "service_role";



GRANT ALL ON FUNCTION "public"."http_patch"("uri" character varying, "content" character varying, "content_type" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_patch"("uri" character varying, "content" character varying, "content_type" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_patch"("uri" character varying, "content" character varying, "content_type" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_patch"("uri" character varying, "content" character varying, "content_type" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "data" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."http_post"("post_url" "text", "post_body" "text", "post_headers" "public"."http_header"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."http_post"("post_url" "text", "post_body" "text", "post_headers" "public"."http_header"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_post"("post_url" "text", "post_body" "text", "post_headers" "public"."http_header"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "content" character varying, "content_type" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "content" character varying, "content_type" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "content" character varying, "content_type" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_post"("uri" character varying, "content" character varying, "content_type" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_put"("uri" character varying, "content" character varying, "content_type" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_put"("uri" character varying, "content" character varying, "content_type" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_put"("uri" character varying, "content" character varying, "content_type" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_put"("uri" character varying, "content" character varying, "content_type" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."http_request"("http_method" "text", "http_url" "text", "http_headers" "text"[], "http_body" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."http_request"("http_method" "text", "http_url" "text", "http_headers" "text"[], "http_body" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_request"("http_method" "text", "http_url" "text", "http_headers" "text"[], "http_body" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."http_reset_curlopt"() TO "postgres";
GRANT ALL ON FUNCTION "public"."http_reset_curlopt"() TO "anon";
GRANT ALL ON FUNCTION "public"."http_reset_curlopt"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_reset_curlopt"() TO "service_role";



GRANT ALL ON FUNCTION "public"."http_set_curlopt"("curlopt" character varying, "value" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."http_set_curlopt"("curlopt" character varying, "value" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."http_set_curlopt"("curlopt" character varying, "value" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."http_set_curlopt"("curlopt" character varying, "value" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."schedule_coffee_fortune_notifications"() TO "anon";
GRANT ALL ON FUNCTION "public"."schedule_coffee_fortune_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."schedule_coffee_fortune_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."schedule_horoscope_notifications"() TO "anon";
GRANT ALL ON FUNCTION "public"."schedule_horoscope_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."schedule_horoscope_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."send_notification"("p_user_id" "uuid", "p_type" "text", "p_title" "text", "p_body" "text", "p_data" "jsonb", "p_scheduled_for" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."send_notification"("p_user_id" "uuid", "p_type" "text", "p_title" "text", "p_body" "text", "p_data" "jsonb", "p_scheduled_for" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_notification"("p_user_id" "uuid", "p_type" "text", "p_title" "text", "p_body" "text", "p_data" "jsonb", "p_scheduled_for" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."send_notification_trigger"() TO "anon";
GRANT ALL ON FUNCTION "public"."send_notification_trigger"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_notification_trigger"() TO "service_role";



GRANT ALL ON FUNCTION "public"."send_push_notification"("p_token" "text", "p_title" "text", "p_body" "text", "p_type" "text", "p_notification_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."send_push_notification"("p_token" "text", "p_title" "text", "p_body" "text", "p_type" "text", "p_notification_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_push_notification"("p_token" "text", "p_title" "text", "p_body" "text", "p_type" "text", "p_notification_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean, "api_key" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean, "api_key" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."test_http_request"("test_user_id" "uuid", "is_test" boolean, "api_key" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."text_to_bytea"("data" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."text_to_bytea"("data" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."text_to_bytea"("data" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."text_to_bytea"("data" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_last_sign_in"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_last_sign_in"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_last_sign_in"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_notification_preferences"("p_user_id" "uuid", "p_horoscope_enabled" boolean, "p_coffee_enabled" boolean, "p_horoscope_time" "text", "p_coffee_times" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."update_notification_preferences"("p_user_id" "uuid", "p_horoscope_enabled" boolean, "p_coffee_enabled" boolean, "p_horoscope_time" "text", "p_coffee_times" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_notification_preferences"("p_user_id" "uuid", "p_horoscope_enabled" boolean, "p_coffee_enabled" boolean, "p_horoscope_time" "text", "p_coffee_times" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."urlencode"("string" "bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."urlencode"("string" "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."urlencode"("string" "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."urlencode"("string" "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."urlencode"("data" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "public"."urlencode"("data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."urlencode"("data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."urlencode"("data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."urlencode"("string" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."urlencode"("string" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."urlencode"("string" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."urlencode"("string" character varying) TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;


















GRANT ALL ON TABLE "public"."fcm_tokens" TO "anon";
GRANT ALL ON TABLE "public"."fcm_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."fcm_tokens" TO "service_role";



GRANT ALL ON TABLE "public"."fortune_readings" TO "anon";
GRANT ALL ON TABLE "public"."fortune_readings" TO "authenticated";
GRANT ALL ON TABLE "public"."fortune_readings" TO "service_role";



GRANT ALL ON TABLE "public"."horoscopes" TO "anon";
GRANT ALL ON TABLE "public"."horoscopes" TO "authenticated";
GRANT ALL ON TABLE "public"."horoscopes" TO "service_role";



GRANT ALL ON TABLE "public"."notification_settings" TO "anon";
GRANT ALL ON TABLE "public"."notification_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."notification_settings" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
