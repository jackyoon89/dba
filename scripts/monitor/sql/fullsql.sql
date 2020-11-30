set long 100000
set pagesize 800

select sql_text from dba_hist_sqltext where sql_id = '&sql_id';

