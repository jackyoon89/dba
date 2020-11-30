set line 130
set pagesize 0

select plan_table_output from table(dbms_xplan.display_cursor('&1',&2, format=>'ALLSTATS LAST ALIAS'))
/

