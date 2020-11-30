set line 180
set pagesize 0
set long 30000
set verify off
rem set feedback off


select * from table(dbms_xplan.display_cursor('&1'))
/

exit

