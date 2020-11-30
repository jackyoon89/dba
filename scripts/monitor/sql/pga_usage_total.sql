set line 130

col PGA_USED_MEM format 999,999,999,999
col PGA_MAX_MEM format 999,999,999,999
col PGA_ALLOC_MEM format 999,999,999,999
col PGA_FREEABLE_MEM format 999,999,999,999

select s.username,sum(PGA_USED_MEM) PGA_USED_MEM,sum(PGA_ALLOC_MEM) PGA_ALLOC_MEM,sum(PGA_FREEABLE_MEM) PGA_FREEABLE_MEM,sum(PGA_MAX_MEM) PGA_MAX_MEM
from gv$session s, gv$process p
where s.paddr = p.addr
group by s.username
/

exit
