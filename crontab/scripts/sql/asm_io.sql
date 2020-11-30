rem Output will be read by crontab user on FXPROD database
rem using external table
rem
rem create table asm_io
rem ( group_name      varchar2(30),
rem   disk_name       varchar2(30),
rem   bytes_read      number,
rem   bytes_write     number,
rem   bytes_per_read  number,
rem   bytes_per_write number )
rem  organization external
rem  (
rem  type oracle_loader
rem  default directory temp_dir
rem  access parameters (
rem       records delimited by newline
rem       fields terminated by '|'
rem  ) location ( 'asm_io.txt')
rem  );
rem

set line 180
set heading off
set feedback off


select  g.name||'|'||d.name||'|'||BYTES_READ/read_time||'|'||BYTES_WRITTEN/write_time||'|'||BYTES_READ/reads||'|'||bytes_written/writes
from v$asm_disk d, v$asm_diskgroup g
where d.group_number = g.group_number
/


exit

