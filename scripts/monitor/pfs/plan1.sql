set line 250
set pagesize 800

select plan_table_output from table(dbms_xplan.display_cursor('&1','&2'))
/

