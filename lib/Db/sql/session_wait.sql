set line 150
col sid    format 999
col event  format a30
col p1text format a15
col p2text format a15
col p3text format a15
col state  format a15

select sid,event, p1,p1text,p2,p2text,p3,p3text,wait_time,state
from v$session_wait
where event not like 'rdbms ipc%'
  and event not like 'SQL*Net%'
  and event not like 'queue%'
/
