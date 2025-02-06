DO $$
BEGIN
    -- Debug bilgisi
    RAISE NOTICE 'Kullanıcı ekleme işlemi başlıyor...';
    
    -- auth.users tablosundaki veriyi kontrol et
    DECLARE
        v_user_exists boolean;
    BEGIN
        SELECT EXISTS (
            SELECT 1 FROM auth.users 
            WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b'
        ) INTO v_user_exists;
        
        IF v_user_exists THEN
            RAISE NOTICE 'Kullanıcı auth.users tablosunda bulundu';
        ELSE
            RAISE NOTICE 'Kullanıcı auth.users tablosunda bulunamadı';
        END IF;
    END;
    
    -- Kullanıcıyı ekle
    INSERT INTO public.users (id, email, created_at, updated_at)
    SELECT 
        id,
        email,
        created_at,
        last_sign_in_at as updated_at
    FROM auth.users
    WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b';
    
    RAISE NOTICE 'Kullanıcı başarıyla eklendi';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'HATA: Kullanıcı zaten var';
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'HATA: Foreign key ihlali';
    WHEN OTHERS THEN
        RAISE NOTICE 'HATA: % %', SQLERRM, SQLSTATE;
END $$; 