col machine format a17
col program format a27
col username format a10
col tablespace format a10
set line 130

select b.sid,a.segtype,a.username,b.status,b.machine,b.program,a.tablespace,a.extents
from v$sort_usage a , v$session b
where a.session_addr = b.saddr
/
