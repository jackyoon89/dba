set line 180
col begin_interval_time format a30

alter session set nls_date_format='yyyy/mm/dd hh24:mi';

accept start_time prompt "Enter Start Time(yyyy/mm/dd hh24:mi): "
accept end_time prompt "Enter End Time(yyyy/mm/dd hh24:mi): "

select h.begin_interval_time, s.sql_id, s.PLAN_HASH_VALUE, s.FETCHES_TOTAL, (s.DISK_READS_TOTAL +  s.BUFFER_GETS_TOTAL)/EXECUTIONS_TOTAL IO_PER_EXEC
  from dba_hist_sqlstat s,
       (select snap_id, begin_interval_time
          from dba_hist_snapshot
         where BEGIN_INTERVAL_TIME between to_date('&start_time','yyyy/mm/dd hh24:mi') and to_date('&end_time','yyyy/mm/dd hh24:mi' )
       ) h
 where s.snap_id  = h.snap_id
order by 5
/
