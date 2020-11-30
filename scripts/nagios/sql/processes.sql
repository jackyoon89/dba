rem
rem This script returns percent of exisitng processes vursus total defined number of processes.
rem 

set line 180
set heading off
set feedback off
col current_processes format 999999999999
col total_processes   format 999999999999

SELECT (SELECT COUNT(*) FROM V$PROCESS) ||' '|| VALUE FROM V$PARAMETER WHERE NAME = 'processes'
/


exit

