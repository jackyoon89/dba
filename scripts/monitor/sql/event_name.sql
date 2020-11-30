set line 180
set pagesize 80
col wait_class format a20

select wait_class#, wait_class_id, wait_class
  from v$event_name
 group by wait_class#, wait_class_id, wait_class
 order by 1
/
