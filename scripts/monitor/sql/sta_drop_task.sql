whenever sqlerror exit failure;


prompt ------> Drop SQL TUNING ADVISOR(STA) TASK
prompt


prompt ------> Current Tasks

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

set line 180
col task_name format a30
col owner format a25

select owner, task_name, status, execution_end from dba_advisor_log
where task_name not like 'ADDM%'
  and task_name not like 'SYS%'
order by 3
/

accept task_name prompt 'Task Name: ';

begin
    dbms_sqltune.drop_tuning_task (task_name => '&task_name');
end;
/
