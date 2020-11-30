set pagesize 24
set line 80
set heading on
set verify off
set feedback off

insert into crontab.INDEX_MONITORING_USAGE
select to_char(s.begin_interval_time,'mm-dd-yy hh24'),p.object_name,p.OBJECT_OWNER
  from dba_hist_sql_plan p, dba_hist_sqlstat t, dba_hist_snapshot s
 where p.sql_id = t.sql_id
   and t.snap_id = s.snap_id
   and p.object_type like 'INDEX'
   and p.OBJECT_OWNER in ('WHITNEY','IPS','IPS_REPORT','READONLY','EFXPH','WMX')
   and (s.begin_interval_time between (sysdate - 2/24) and (sysdate - 1/24))
/

commit
/

exit
