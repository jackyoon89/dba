col sql_id FOR a15 
col sql_id FOR a15
SET pages 50 lines 220 
col TEXT FOR a50

SELECT stat.sql_id,
       plan_hash_value,
       rpad(stat.parsing_schema_name, 10) "schema",
       elapsed_time_total/1000000/60 "minutes",
       round(stat.elapsed_time_total/1000000/60/60, 1) "Hours",
       elapsed_time_delta,
       disk_reads_delta,
       stat.executions_total,
       to_char(ss.BEGIN_INTERVAL_TIME, 'dd-mm-yy hh24:mi:ss') "BeginTime",
       to_char(ss.end_interval_time, 'dd-mm-yy hh24:mi:ss') "EndTime",
       rpad(txt.sql_text, 40) text,ss.snap_id
FROM dba_hist_sqlstat stat,
     dba_hist_sqltext txt,
     dba_hist_snapshot ss
WHERE stat.sql_id = txt.sql_id
  AND stat.dbid = txt.dbid
  AND ss.dbid = stat.dbid
  AND ss.instance_number = stat.instance_number
  AND stat.snap_id = ss.snap_id
  AND stat.sql_id = '&sqlid'
ORDER BY 8 DESC 
/
