set heading off
set feedback off
set line 80
set pagesize 80

select 'thread'||thread#||':'||count(*)
  from v$log_history 
 where  first_time >= sysdate - 1/24
 group by thread#
/

exit
