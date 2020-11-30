rem
rem Monitor SQL Memory Usage
rem

set line 180
col sql_text format a80

select wa.sql_id,sql_text, 
       sum(onepass_executions) onepass_cnt,
       sum(multipasses_executions) multi_path_cnt 
  from v$sql s, v$sql_workarea wa
 where s.address = wa.address
 group by wa.sql_id,sql_text
 having sum(onepass_executions + multipasses_executions) > 0
/
