
set line 180
set heading off
set feedback off

select round((sysdate - alive_time)*24*60 , 2) from crontab.heartbeat
/

exit


