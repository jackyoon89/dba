set lines 1800
col mesg format a1800
set pages 0
set trim on
set trimspool on
set feedback off
set long 50000

select owner||'.'||job_name||'('||nvl(status,'N/A')||' - '||to_char(log_date, 'mm/dd/yyyy,hh24:mi:ss')|| decode(status,NULL, ' - '||additional_info, NULL)||')' mesg
from
(
select 
    log_date
  , owner
  , job_name
  , status
  , additional_info
  , row_number() over (partition by owner, job_name order by log_date desc) rn 
from 
  dba_scheduler_job_log
where log_date >= sysdate - 1
  and job_name in (select job_name from dba_scheduler_jobs where enabled = 'TRUE')
)
where 
  rn = 1
order by
  log_date desc
;

exit
