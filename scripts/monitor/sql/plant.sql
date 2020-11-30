set line 180
set pagesize 0

select plan_table_output from table(dbms_xplan.display('PLAN_TABLE',format=>'ALLSTATS LAST ALIAS'))
/

