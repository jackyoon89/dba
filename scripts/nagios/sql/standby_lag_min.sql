rem
rem This script returns standby database lag time(min).
rem

set line 180
set heading off
set feedback off
set verify off


SELECT ROUND((MAX(PRIMARY_TIME) - MAX(STANDBY_TIME)) * 24 * 60 , 2)
  FROM ( SELECT MAX(NEXT_TIME) PRIMARY_TIME, TO_DATE(null) STANDBY_TIME
           FROM V$ARCHIVED_LOG
          WHERE ARCHIVED  = 'YES'
            AND DEST_ID = 1
          UNION ALL
         SELECT TO_DATE(NULL), MAX(NEXT_TIME)
           FROM V$ARCHIVED_LOG
          WHERE ARCHIVED  = 'YES'   -- AND APPLIED = 'YES'
            AND DEST_ID = &1
        )
/


exit

