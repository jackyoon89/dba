rem
rem  Remove SPA Task
rem

whenever sqlerror exit failure;

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

prompt ------> Remove SQL Performance Analyzer Task

set line 125
col owner format a15
col task_name format a25
col advisor_name format a24

select owner, task_name, advisor_name, last_execution, last_modified 
  from dba_advisor_tasks
 where advisor_name = 'SQL Performance Analyzer'
order by owner, task_name;

accept task_name prompt 'SPA Task Name:';

EXEC dbms_sqlpa.drop_analysis_task(upper('&task_name'));

