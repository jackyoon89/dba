set line 180
set pagesize 80

select spb.sql_handle, spb.plan_name, spb.sql_text, spb.enabled, spb.accepted, spb.fixed, to_char(spb.last_executed,'dd-mon-yy HH24:MI') last_executed
 from dba_sql_plan_baselines spb;
