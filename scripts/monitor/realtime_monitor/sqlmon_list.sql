set line 180
set pagesize 80
col sql_text format a80

SELECT sql_id, sql_plan_hash_value, status, sql_text
FROM   v$sql_monitor
where sql_text is not null
/
