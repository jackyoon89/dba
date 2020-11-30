SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SPOOL sql_monitor_&&sql_id._&&plan_hash_value..htm

SELECT DBMS_SQLTUNE.report_sql_monitor(
  sql_id       => '&&sql_id',
  type         => 'HTML',
  sql_plan_hash_value => '&&plan_hash_value',
  report_level => 'ALL') AS report
FROM dual;

SPOOL OFF

