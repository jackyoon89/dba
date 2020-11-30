rem
rem This script returns percent of exisitng processes vursus total defined number of processes.
rem 

set line 180
set heading off
set feedback off

SELECT (SUM(PERCENT_SPACE_USED)  - SUM(PERCENT_SPACE_RECLAIMABLE)) PERCENT_USAGE FROM V$FLASH_RECOVERY_AREA_USAGE
/


exit

