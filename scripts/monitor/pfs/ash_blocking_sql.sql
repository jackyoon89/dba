rem where sample_time between to_date('2014/10/17 02:00','yyyy/mm/dd hh24:mi') and to_date('2014/10/17 03:00','yyyy/mm/dd hh24:mi')
rem    where sample_time between sysdate - 10/(24*60) and sysdate
rem  
   select BLOCKING_SESSION, SQL_CHILD_NUMBER, sql_id, count(*) from v$active_session_history
    where sample_time between to_date('2014/12/08 05:00','yyyy/mm/dd hh24:mi') and to_date('2014/12/08 06:00','yyyy/mm/dd hh24:mi')
      and BLOCKING_SESSION is not null
   group by BLOCKING_SESSION, SQL_CHILD_NUMBER,sql_id
   order by 4
/

