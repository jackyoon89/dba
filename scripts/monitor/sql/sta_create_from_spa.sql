whenever sqlerror exit failure;

set serverout on


prompt ------> Create SQL Tuning Advisor(STA) Task from SQL Performance Analyzer(SPA) Task
prompt

prompt -------> Existing SQL Performance Analyzer Tasks
prompt

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

rem
rem Display SPA Task information
rem
set line 120
col owner format a15
col task_name format a25
col advisor_name format a24

select owner, task_name, advisor_name, last_execution, last_modified
  from dba_advisor_tasks
 where advisor_name = 'SQL Performance Analyzer'
order by owner, task_name;

accept task_name  prompt 'SPA Task Name: ';


rem
rem Display Compare execution information
rem
select owner, execution_name, execution_type, status, execution_end
  from dba_advisor_executions
 where task_name = '&task_name'
   and execution_type = 'COMPARE PERFORMANCE'
order by execution_type desc, execution_end;

accept compare_exec prompt 'SPA Execution Name: ';



declare
  l_sql_tune_task_id  VARCHAR2(100);
begin
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          spa_task_name => '&task_name',
                          spa_compare_exec => '&compare_exec',
                          time_limit  => 60,
                          task_name   => '&compare_exec'||'_tuning_task',
                          description => 'Tuning task for SPA &task_name'||'_'||'&compare_exec'||'.');

  dbms_output.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
end;
/


exec dbms_sqltune.execute_tuning_task(task_name => '&compare_exec'||'_tuning_task');


