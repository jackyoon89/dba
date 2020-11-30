set line 180
set pagesize 80
col owner format a10
col task_name format a30
alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select owner, task_id, task_name, execution_start, execution_end, status, activity_counter, recommendation_count from dba_advisor_log
order by task_id
/
