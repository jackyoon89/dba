rem where sample_time between sysdate -1/24 and sysdate

select event, sql_id, count(*) from v$active_session_history
    where sample_time between to_date('2014/12/08 05:00','yyyy/mm/dd hh24:mi') and to_date('2014/12/08 06:00','yyyy/mm/dd hh24:mi')
   and sql_id is not null
   and event is not null
group by event, sql_id
order by 1,3
/
