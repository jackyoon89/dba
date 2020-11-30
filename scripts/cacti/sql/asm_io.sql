set heading off
set feedback off
set line 180
set pagesize 80
set verify off

select 'bytes_read:'||trunc(sum(BYTES_READ)/2)||' bytes_write:'||trunc(sum(BYTES_WRITE)/2)||
      ' bytes_per_read:'||trunc(sum(BYTES_PER_READ)/2)||' bytes_per_write:'||trunc(sum(BYTES_PER_WRITE)/2)
from asm_io
where group_name = upper('&1')
group by group_name
/

exit
