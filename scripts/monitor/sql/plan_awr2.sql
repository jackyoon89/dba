set linesize 180
set pagesize 500
rem select * from TABLE(dbms_xplan.display_awr('&1',&2, format=>'allstats last alias +adaptive'));
select * from TABLE(dbms_xplan.display_awr('&1',&2));

