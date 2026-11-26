USE sptrans;
SELECT * FROM vw_kpis;
SELECT table_name, column_name, referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'sptrans' AND referenced_table_name IS NOT NULL;