whenever sqlerror exit failure;

set serverout on


prompt ------> Create SQL Tuning Advisor(STA) Task from cursor for a sql_id


declare
  l_sql_tune_task_id  VARCHAR2(100);
begin
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => '&&sql_id',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 120,
                          task_name   => '&&sql_id'||'_AWR_tuning_task',
                          description => 'Tuning task for statement &&sql_id.');
  dbms_output.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
end;
/


exec dbms_sqltune.execute_tuning_task(task_name => '&&sql_id'||'_AWR_tuning_task');


