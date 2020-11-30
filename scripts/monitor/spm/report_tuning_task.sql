SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200

ACC task_name prompt 'Input tuning Task_name : '

SELECT DBMS_SQLTUNE.report_tuning_task('&task_name') AS recommendations FROM dual;
