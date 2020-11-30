set heading off
set feedback off

select name
  from v$pdbs
 where con_id > 2;

exit

