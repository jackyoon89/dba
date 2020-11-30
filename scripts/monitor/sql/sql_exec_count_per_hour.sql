set line 180
col executions format 999,999,999,999

SELECT to_char(ss.BEGIN_INTERVAL_TIME, 'yyyy/mm/dd hh24') "BeginTime",
       sum(stat.executions_total) executions
FROM dba_hist_sqlstat stat,
     dba_hist_sqltext txt,
     dba_hist_snapshot ss
WHERE stat.sql_id = txt.sql_id
  AND stat.dbid = txt.dbid
  AND ss.dbid = stat.dbid
  AND ss.instance_number = stat.instance_number
  AND stat.snap_id = ss.snap_id
  AND stat.sql_id = '&sqlid'
group by to_char(ss.BEGIN_INTERVAL_TIME, 'yyyy/mm/dd hh24')
ORDER BY 1 
/
