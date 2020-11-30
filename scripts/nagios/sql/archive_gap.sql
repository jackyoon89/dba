rem
rem This script returns percent of exisitng processes vursus total defined number of processes.
rem 

set line 180
set heading off
set feedback off

rem SELECT COUNT(*) FROM V$ARCHIVE_GAP
rem WHERE EXISTS (SELECT 1
rem                 FROM V$ARCHIVE_DEST
rem                WHERE DEST_ID > 1
rem                  AND STATUS = 'VALID')
rem /

rem Workaround to avoid timeout
SELECT count(*)
  FROM (  SELECT a.thread#, rcvsq, MIN (a.sequence#) - 1 hsq
            FROM v$archived_log a,
                 (  SELECT thread#, resetlogs_change#, MAX (sequence#) rcvsq
                      FROM v$log_history
                     WHERE (thread#, resetlogs_change#, resetlogs_time) IN
                              (SELECT /*+ no_unnest */ lh.thread#,
                                      lh.resetlogs_change#,
                                      lh.resetlogs_time
                                 FROM v$log_history lh, v$database_incarnation di
                                WHERE     lh.resetlogs_time = di.resetlogs_time
                                      AND lh.resetlogs_change# =
                                             di.resetlogs_change#
                                      AND di.status = 'CURRENT')
                  GROUP BY thread#, resetlogs_change#) b
           WHERE     a.thread# = b.thread#
                 AND a.resetlogs_change# = b.resetlogs_change#
                 AND a.sequence# > rcvsq
        GROUP BY a.thread#, rcvsq) high,
       (SELECT srl_lsq.thread#, NVL (lh_lsq.lsq, srl_lsq.lsq) lsq
          FROM (  SELECT thread#, MIN (sequence#) + 1 lsq
                    FROM v$log_history lh,
                         x$kccfe fe,
                         v$database_incarnation di
                   WHERE     TO_NUMBER (fe.fecps) <= lh.next_change#
                         AND TO_NUMBER (fe.fecps) >= lh.first_change#
                         AND fe.fedup != 0
                         AND BITAND (fe.festa, 12) = 12
                         AND di.resetlogs_time = lh.resetlogs_time
                         AND lh.resetlogs_change# = di.resetlogs_change#
                         AND di.status = 'CURRENT'
                GROUP BY thread#) lh_lsq,
               (  SELECT thread#, MAX (sequence#) + 1 lsq
                    FROM v$log_history
                   WHERE (SELECT MIN (TO_NUMBER (fe.fecps))
                            FROM x$kccfe fe
                           WHERE fe.fedup != 0 AND BITAND (fe.festa, 12) = 12) >=
                            next_change#
                GROUP BY thread#) srl_lsq
         WHERE srl_lsq.thread# = lh_lsq.thread#(+)) low
 WHERE low.thread# = high.thread# AND lsq <= hsq AND hsq > rcvsq
/

exit

