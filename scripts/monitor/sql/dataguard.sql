set echo off pause off numw 8 lines 300 timing off pages 10000 trimsp on tab off
column NAME_COL_PLUS_SHOW_PARAM format a30
column VALUE_COL_PLUS_SHOW_PARAM format a80 wrap
col bytes for 999999999999
col name for a40
col dest_name for a20
col value for a18
col status for a12
col stby for a4
col error for a5
col type for a15
col destination for a25
col database_mode heading 'DATABASE|MODE' for a15
col database_role heading 'DATABASE|ROLE' for a18
col recovery_mode heading 'RECOVERY|MODE' for a23
col db_unique_name heading 'DB|UNIQUE_NAME' for a15
col open_mode heading 'OPEN|MODE' for a22
col remote_archive heading 'REMOTE|ARCHIVE' for a10
col primary_db_unique_name heading 'PRIMARY_DB|UNIQUE_NAME' for a15
col switchover_status heading 'SWITCHOVER|STATUS' for a18
col client_process heading 'CLIENT|PROCESS' for a10
col delay_mins heading 'DELAY|MINS' for 99999
col mountid heading 'MOUNT|ID' for 9999
col dataguard_broker heading 'DATAGUARD|BROKER' for a10
col inst for 9999
col dest for 9999
col process for a8
col dg_broker for a9
col gap_status for a15
col message for a35 wrap
col error for a80
col INSTANCE for a20
break on inst skip 1
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set echo off
pro
pro *** v$database ***
select DB_UNIQUE_NAME,OPEN_MODE,DATABASE_ROLE,PROTECTION_MODE,REMOTE_ARCHIVE,SWITCHOVER_STATUS,DATAGUARD_BROKER
-- Uncomment for 11gR2
,PRIMARY_DB_UNIQUE_NAME
from v$database
;
pro *** v$thread ***
select thread#, status, enabled, groups, instance, sequence# "CURRENT LOG SEQUENCE"
from v$thread
;
pro *** v$log ***
select thread#, count(*) from v$log group by thread# order by 1,2
;
pro *** v$standby_log ***
select thread#, count(*) from v$standby_log group by thread# order by 1,2
;
pro *** gv$archive_dest_status ***
select
s.INST_ID inst, s.DEST_ID dest, d.target, s.db_unique_name, d.destination, s.DATABASE_MODE, s.STATUS, s.RECOVERY_MODE,d.schedule,d.process
from gv$archive_dest_status s, gv$archive_dest d
where s.dest_id=d.dest_id
and s.inst_id=d.inst_id
and s.status<>'INACTIVE'
order by s.INST_ID, s.DEST_ID
;
select
s.INST_ID inst, s.DEST_ID dest, s.status, s.srl, s.GAP_STATUS, NVL(s.ERROR,'NONE') error
from gv$archive_dest_status s
where s.status<>'INACTIVE'
order by s.INST_ID, s.DEST_ID
;
pro *** v$archived_log ***
select to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') time, a.thread#,
(select max(sequence#) from v$archived_log where archived='YES' and thread#=a.thread#) archived,
max(a.sequence#) applied,
(select max(sequence#) from v$archived_log where archived='YES' and thread#=a.thread#)-max(a.sequence#) gap
from v$archived_log a
where a.applied='YES'
group by a.thread#
order by a.thread#
;
pro *** gv$dataguard_status ***
select inst_id inst,facility,severity,dest_id dest,error_code,timestamp,message
from (
select * from gv$dataguard_status order by message_num desc
) where rownum <11 order by timestamp desc, severity desc
;
col name for a25
pro *** gv$dataguard_stats ***
select inst_id inst, name,value,unit, time_computed
from gv$dataguard_stats
order by time_computed asc, name asc
;
pro *** gv$managed_standby ***
select inst_id inst,PID,thread#,client_process,process,status,sequence#,block#,DELAY_MINS
from gv$managed_standby
where status not in ('CLOSING','IDLE','CONNECTED')
order by inst_id, status desc, thread#, sequence#
;
set echo off pause off

