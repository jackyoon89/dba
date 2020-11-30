set heading off
set feedback off
set line 80
set pagesize 80


select v.stat_name||':'||(v.value - c.value)
  from v$osstat v, cacti_osstat c
 where v.stat_name = c.stat_name
   and v.stat_name in (
'IDLE_TIME','BUSY_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME')
/

delete from cacti_osstat
/

insert into cacti_osstat
select stat_name,value
  from v$osstat
where stat_name in (
'IDLE_TIME','BUSY_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME')
/

commit
/


exit

