set line 180
set pagesize 80
col username format a15
col sample_time format a30
col event format a35
alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select session_id, (select username from dba_users u where u.user_id = s.user_id) username, sql_id,SQL_CHILD_NUMBER,SQL_PLAN_HASH_VALUE, count(*)
from v$active_session_history s
where sample_time between sysdate - 1/24 and sysdate
group by session_id, user_id , sql_id,SQL_CHILD_NUMBER,SQL_PLAN_HASH_VALUE
order by 6 
/

