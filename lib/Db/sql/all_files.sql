set line 100
set heading off
set feedback off
set verify off

select * from (
select name from v$dbfile
union 
select name from v$tempfile
union
select member from v$logfile
union 
select name from v$controlfile
) order by 1
/

exit

