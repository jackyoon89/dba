whenever sqlerror exit failure;


prompt ------> Report SQL Tuning Advisror(STA) TASK
prompt


alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

prompt ------> Current Tasks

select task_name, status, execution_end from dba_advisor_log
where task_name not like 'ADDM%'
  and task_name not like 'SYS%'
order by 3
/

accept task_name prompt 'Task Name: ';

set long 100000000;
set pagesize 1000
set linesize 250

spool &task_name..txt
select dbms_sqltune.report_tuning_task (task_name => '&task_name') as recommendations from dual;
spool off
