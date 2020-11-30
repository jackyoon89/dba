set line 130

col PGA_USED_MEM format 999,999,999,999
 
select s.inst_id, s.sid, s.username,PGA_USED_MEM ,PGA_ALLOC_MEM,PGA_FREEABLE_MEM,PGA_MAX_MEM
from gv$session s, gv$process p
where s.paddr = p.addr
  and s.inst_id = p.inst_id
  and s.username is not null
  and s.username <> 'SYS'
  and s.status = 'ACTIVE'
order by s.username
/

