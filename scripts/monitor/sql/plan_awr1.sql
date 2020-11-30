set linesize 180
set pagesize 500
select * from TABLE(dbms_xplan.display_awr('&1', null, null, 'allstats last alias advanced'));

