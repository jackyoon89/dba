rem
rem This script returns percent of exisitng processes vursus total defined number of processes.
rem 

set line 180
set heading off
set feedback off
set verify off

select dest_id,THREAD#,SEQUENCE#,ARCHIVED,APPLIED
  from v$archived_log
 where first_change# = (select max(first_change#) from v$archived_log where first_time <= sysdate-(1/24))
   and dest_id = &1
/


exit

