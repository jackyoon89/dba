DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN

  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id => 'grqr49c4qvm27',
                          task_name   => 'tune_task1');

  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/


exit;

exec dbms_sqltune.execute_tuning_task( task_name => 'tune_task1');

exec dbms_sqltune.interrupt_tuning_task( task_name => 'tune_task1');
exec dbms_sqltune.resume_tuning_task ( task_name => 'tune_task1');
exec dbms_sqltune.cancel_tuning_task ( task_name => 'tune_task1');
exec dbms_sqltune.reset_tuning_task (task_name => 'tune_task1');
exec dbms_sqltune.drop_tuning_task (task_name => 'tune_task1');



rem check
select task_name,status from dba_advisor_log where task_name = 'tune_task1';

SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200

SELECT DBMS_SQLTUNE.report_tuning_task('tune_task1') AS recommendations FROM dual;

SET SERVEROUTPUT ON
DECLARE
  l_sql_tune_task_id  VARCHAR2(20);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.accept_sql_profile (
                          task_name => 'tune_task1');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

rem disable sql_profile
begin
    dbms_sqltune.alter_sql_profile (
       name => '&1',
       attribute_name => 'STATUS',
       value => 'DISABLED');
end;
/

