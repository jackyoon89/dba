alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select alr.arcr "Date/Time Applied",
al.thrd "Thread",
almax "Last Seq Received", lhmax "Last Seq Applied",
-- lha.arca "ARCH Applied",
  (almax - lhmax) "Difference"
  from (select thread# thrd, max(completion_time) arcr
      from gv$archived_log where applied in ('YES','IN-MEMORY') group by thread#) alr,
       (select thread# thrd, max(sequence#) almax
        from gv$archived_log
           where resetlogs_change#=(select resetlogs_change# from v$database)
             group by thread#) al,
     (select thread# thrd, max(first_time) arca
        from gv$log_history group by thread#) lha,
     (select thread# thrd, max(sequence#) lhmax
        from gv$log_history
           -- where FIRST_CHANGE#=(select max(FIRST_CHANGE#) from gv$log_history)
             group by thread#) lh
where al.thrd = lh.thrd
  and alr.thrd = lha.thrd
  and alr.thrd = lh.thrd;
 

