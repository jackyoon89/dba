set linesize 180
set pagesize 200
col message for a50
col CALLER for a30


set verify off
set serverout on echo on feedback on

alter session set container=&1;

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

truncate table utl$log;


BEGIN

insert into wmx_archive.TRADE_SNAP_PROBLEM
select * from wmx.TRADE_SNAP_PROBLEM wt
where
wt.TRADE_SNAP_PROBLEM_ID>
(select max(TRADE_SNAP_PROBLEM_ID) from wmx_archive.TRADE_SNAP_PROBLEM)
;

insert into wmx_archive.QUOTESNAPHISTORY
select * from wmx.QUOTESNAPHISTORY wt
where
wt.QUOTESNAP_HISTORY_ID>
(select max(QUOTESNAP_HISTORY_ID) from wmx_archive.QUOTESNAPHISTORY)
;

insert into wmx_archive.QUOTESNAPPROBLEM
select * from wmx.QUOTESNAPPROBLEM wt
where
wt.QUOTESNAP_PROBLEM_ID>
(select max(QUOTESNAP_PROBLEM_ID) from wmx_archive.QUOTESNAPPROBLEM)
;

insert into wmx_archive.TRADESNAP
select * from wmx.TRADESNAP wt
where
wt.TRADE_SNAP_ID>
(select max(TRADE_SNAP_ID) from wmx_archive.TRADESNAP)
;

insert into wmx_archive.QUOTESNAP
select * from wmx.QUOTESNAP wt
where
wt.QUOTE_SNAP_ID>
(select max(QUOTE_SNAP_ID) from wmx_archive.QUOTESNAP)
;

insert into wmxfwd_history.QUOTESNAP
select * from wmxfwd.QUOTESNAP wt
where
wt.QUOTE_SNAP_ID>
(select nvl(max(QUOTE_SNAP_ID),0) from wmxfwd_history.QUOTESNAP)
;

insert into wmxfwd_history.QUOTESNAPHISTORY
select * from wmxfwd.QUOTESNAPHISTORY wt
where
wt.QUOTESNAP_HISTORY_ID>
(select nvl(max(QUOTESNAP_HISTORY_ID),0) from wmxfwd_history.QUOTESNAPHISTORY)
;

insert into wmxfwd_history.QUOTESNAPPROBLEM
select * from wmxfwd.QUOTESNAPPROBLEM wt
where
wt.QUOTESNAP_PROBLEM_ID>
(select nvl(max(QUOTESNAP_PROBLEM_ID),0) from wmxfwd_history.QUOTESNAPPROBLEM)
;

commit;

UTL_PURGE.PURGE_DATA_CASCADE('WMX','QUOTESNAP','SELECT QUOTE_SNAP_ID FROM WMX.QUOTESNAP WHERE LAST_SNAP_TIME_GMT<SYSDATE-&2',1);

UTL_PURGE.PURGE_DATA_CASCADE('WMX','TRADESNAP','SELECT TRADE_SNAP_ID FROM WMX.TRADESNAP WHERE LAST_SNAP_TIME_GMT<SYSDATE-&2',1);

UTL_PURGE.PURGE_DATA_CASCADE('WMX','TRADE_SNAP_PROBLEM','SELECT TRADE_SNAP_PROBLEM_ID FROM WMX.TRADE_SNAP_PROBLEM WHERE TRADE_PROBLEM_TIME_GMT<SYSDATE-&2',1);

UTL_PURGE.PURGE_DATA_CASCADE('WMX','FIXED_SPOT_RATE','SELECT FIXED_SPOT_RATE_ID FROM WMX.FIXED_SPOT_RATE where FIX_TIME_GMT <= ADD_MONTHS(SYSDATE, -5) AND IS_PUBLISHED = 0',1);

UTL_PURGE.PURGE_DATA_CASCADE('WMXFWD','QUOTESNAP','SELECT QUOTE_SNAP_ID FROM WMXFWD.QUOTESNAP WHERE LAST_SNAP_TIME_GMT<SYSDATE-&2',1);

UTL_PURGE.PURGE_DATA_CASCADE('WMXFWD','FIXED_SPOT_RATE','SELECT FIXED_SPOT_RATE_ID FROM WMXFWD.FIXED_SPOT_RATE where FIX_TIME_GMT <= ADD_MONTHS(SYSDATE, -5) AND IS_PUBLISHED = 0',1);

UTL_PURGE.PURGE_DATA_CASCADE('WMXFWD','FIXED_SPOT_RATE','SELECT FIXED_SPOT_RATE_ID FROM WMXFWD.FIXED_SPOT_RATE where FIX_TIME_GMT <= ADD_MONTHS(SYSDATE, -5) AND IS_PUBLISHED = 0',1);

dbms_stats.gather_schema_stats(ownname=>'WMX', estimate_percent=>20, method_opt=>'FOR ALL COLUMNS SIZE AUTO', degree=>8, granularity=>'ALL', cascade=>TRUE);

END;
/


SELECT log#,datetime,task,caller,message
  FROM sys.utl$log
 ORDER BY log#
/

exit;
