rem
rem This script returns percent of exisitng processes vursus total defined number of processes.
rem 

set line 180
set heading off
set feedback off

SELECT DEST_NAME||','||ERROR FROM V$ARCHIVE_DEST
WHERE STATUS NOT IN ( 'VALID', 'INACTIVE' )
/


exit

