set line 180
set pagesize 8000

select username, program, PGA_USED_MEM, PGA_ALLOC_MEM, PGA_MAX_MEM from v$process
 order by PGA_MAX_MEM
/

