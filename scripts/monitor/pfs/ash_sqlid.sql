
select (select username from dba_users d where d.user_id = h.user_id) as user_id,sql_id , count(*) from v$active_session_history h
 where sample_time between to_date('2014/12/08 05:00','yyyy/mm/dd hh24:mi') and to_date('2014/12/08 06:00','yyyy/mm/dd hh24:mi')
group by user_id,sql_id
order by 3
/
