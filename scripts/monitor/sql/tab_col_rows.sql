set line 180
col tname format a50
col NUM_DISTINCT format 999,999,999,999
col DENSITY format 999,999,999,999
col NUM_NULLS format 999,999,999,999


breat on tname

select OWNER||'.'||TABLE_NAME TNAME, COLUMN_NAME, NULLABLE, NUM_DISTINCT, DENSITY, NUM_NULLS 
  from dba_tab_columns
where owner = upper('&1')
  and table_name = upper('&2')
/
