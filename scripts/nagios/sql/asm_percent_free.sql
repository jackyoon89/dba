
set line 180
set heading off
set feedback off

col percent_free format 999.99

select name,free_mb/total_mb*100 "percent_free" from v$asm_disk;

exit

