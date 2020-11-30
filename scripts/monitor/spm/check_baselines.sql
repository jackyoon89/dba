set linesize 300
column sql_handle format a20
column plan_name format a42
column sql_text format a42

select sql_handle, plan_name, sql_text, enabled, accepted, fixed from dba_sql_plan_baselines;
