rem
rem Optimal logfile size
rem optimal_logfile_size is depends on the value of fast_start_mttr_target.
rem The bigger the fast_start_mttr_target you have the bigger optimal_logfile_size it recommends.
rem
rem Note: FAST_START_MTTR_TARGET: enables you to specify the number of seconds the database takes to perform crash recovery of a single instance.
rem When specified, FAST_START_MTTR_TARGET is overridden by LOG_CHECKPOINT_INTERVAL
rem

set line 180

select RECOVERY_ESTIMATED_IOS,ACTUAL_REDO_BLKS,TARGET_REDO_BLKS,WRITES_LOGFILE_SIZE,OPTIMAL_LOGFILE_SIZE optimal_logfile_size_mb
  from v$instance_recovery;

