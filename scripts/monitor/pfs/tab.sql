select owner,table_name,num_rows from all_tables where table_name = upper('&1')
/

select COLUMN_NAME, NULLABLE, NUM_NULLS, NUM_DISTINCT from dba_tab_columns where table_name = upper('&1')
/
