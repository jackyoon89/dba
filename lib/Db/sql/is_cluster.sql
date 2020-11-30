set line 100
set heading off
set feedback off
set verify off

select value from v$parameter where name = 'cluster_database'
/

exit
