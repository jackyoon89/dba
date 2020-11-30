set line 180
set heading off
set feedback off
set verify off

select round(sysdate - max(end_time),2)||','||to_char(max(end_time),'yyyy/mm/dd hh24:mi:ss')
  from v$rman_backup_job_details
 where input_type = upper('&1')
   and status = 'COMPLETED'
/

exit
