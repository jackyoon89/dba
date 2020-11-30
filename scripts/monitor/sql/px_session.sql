set line 180
set pagesize 0
col st_lvl format a15
col event format a40
col wait_class format a30

select decode(a.qcserial#,null,'PARENT','CHILD') ST_LVL, 
       a.server_set "SET", a.sid,a.serial#, status, event, wait_class
 from v$px_session a, v$session b
where a.sid = b.sid
  order by a.qcsid, ST_LVL desc , a.server_group , a.server_set;
