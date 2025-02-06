\d fortune_readings;

-- Tablo yapısını detaylı göster
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'fortune_readings'; 