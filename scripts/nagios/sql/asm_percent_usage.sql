
set line 180
set heading off
set feedback off

col percent_free format 999.99

select name,
      case
      when total_mb <> 0 then
           (total_mb - free_mb)/total_mb*100
      end
from v$asm_diskgroup
where name not like '%ACFS%'
  and name not like '%VOTE%' 
/

exit

