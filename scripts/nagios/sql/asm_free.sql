set line 130

select g.name,d.name,d.free_mb,d.total_mb,d.free_mb/d.total_mb*100 from v$asm_disk d, v$asm_diskgroup g
where d.group_number = g.group_number
/
