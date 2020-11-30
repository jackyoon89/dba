col job      format 9999
col log_user format a10
col what     format a54
set heading  on
set feedback off
set line 130

select job,broken,failures,log_user,to_char(next_date,'yyyy/mm/dd hh24:mi:ss') "Next Exec Time", what
  from dba_jobs
 where broken = 'Y'
    or failures <> 0
/ 
