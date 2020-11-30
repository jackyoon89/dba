set line 250
set pagesize 80
col username format a15
col sample_time format a30
col event format a35
alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select inst_id,sample_time, session_id, (select username from dba_users u where u.user_id = s.user_id) username, sql_id, SQL_CHILD_NUMBER,SQL_PLAN_HASH_VALUE, event, session_state, BLOCKING_INST_ID,blocking_session 
  from gv$active_session_history s
where sample_time between to_date('2020/06/18 07:00','yyyy/mm/dd hh24:mi') and to_date('2020/06/18 08:10','yyyy/mm/dd hh24:mi')
order by sample_time
/
