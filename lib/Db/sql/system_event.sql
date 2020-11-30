col event format a40
set line 130

select * 
  from ( select event, total_waits, total_timeouts, time_waited, average_wait
           from v$system_event
          where event not like 'SQL*Net%'
          order by total_waits desc
  ) where rownum <= 10
/
