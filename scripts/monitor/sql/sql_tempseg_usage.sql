rem
rem tempseg usage to monitor space and workload distribution
rem

set line 180
col used_mb format 999,999,999,999

select session_num, username, sql_id, segtype, (blocks*(select value from v$parameter where name = 'db_block_size'))/1024/1024 used_mb, tablespace from v$tempseg_usage
/
