set linesize 180
set pagesize 500

select *
  from table(dbms_xplan.display_sql_plan_baseline(sql_handle => '&sql_handle'));
