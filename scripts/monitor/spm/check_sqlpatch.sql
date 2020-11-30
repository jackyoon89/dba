set line 180
col name format a30
col sql_text format a50

select name, status, created, sql_text from dba_sql_patches;
