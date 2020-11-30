set line 180
col owner format a30
col object_name format a30

select
 so.owner,
 so.object_name,
 --so.subobject_name,
 so.object_type,
 so.tablespace_name,
 round(sum(ss.space_used_delta)/1024/1024) growth_mb
 from
 dba_hist_seg_stat ss,
 dba_hist_seg_stat_obj so
 where
 ss.obj# = so.obj#
 and ss.dataobj# = so.dataobj#
 and so.owner != '** MISSING **' -- segments already gone
 and so.object_name not like 'BIN$%' -- recycle-bin
-- and so.object_type not like 'LOB%'
 and ss.snap_id > (
 select min(sn.snap_id)
 from dba_hist_snapshot sn
 where
 sn.dbid = (select dbid from v$database)
 and sn.end_interval_time > trunc(sysdate) - &DAYS_BACK
 )
 group by
 so.owner,
 so.object_name,
 --so.subobject_name,
 so.object_type,
 so.tablespace_name
 order by 5 desc
 fetch first &TOP rows only;

