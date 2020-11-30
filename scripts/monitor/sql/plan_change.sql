set timing on
set line 180
col ET_SECS_PER_EXEC format a30
 
rem This script checks execution plan of queries that run last 1 hour and compare it's plan with the one for last 7 days.
rem if it's performance was degraded greater than standard deviation then it shows it as a result
rem

SELECT h.sql_id,
       h.plan_hash_value,
       h.executions_total,
       TO_CHAR(ROUND(h.elapsed_time_total / h.executions_total / 1e6, 3), '999,990.000') et_secs_per_exec
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s,
       (SELECT /* Get Average elapsed time and stddev for last 7 days */
               h.sql_id,
               ROUND(avg(h.elapsed_time_total / h.executions_total / 1e6), 2) average,
               ROUND(stddev(h.elapsed_time_total / h.executions_total / 1e6), 2) standard_deviation
          FROM dba_hist_sqlstat h,
               dba_hist_snapshot s
         WHERE h.executions_total > 0
           AND h.plan_hash_value <> 0
           AND s.BEGIN_INTERVAL_TIME > sysdate - 7
           AND s.snap_id = h.snap_id
           AND s.dbid = h.dbid
           AND s.instance_number = h.instance_number
         GROUP BY h.sql_id) std
WHERE h.sql_id = std.sql_id
   AND s.BEGIN_INTERVAL_TIME > sysdate - 1/24  /* compare sqls that are in last 1 hour */
   AND ROUND(h.elapsed_time_total / h.executions_total / 1e6, 2) >= (std.average + std.standard_deviation)  /* get sqls of which the elapsed time is greater than standard deviation */
   AND h.executions_total > 0
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
ORDER BY 4
/

