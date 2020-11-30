accept inst_id prompt "Instance No:"

select snap_id, io_in_bytes/snapshot_in_seconds IOPS
  from ( select snap_id, 
                (sum(small_read_megabytes) + sum(small_write_megabytes) + sum(large_read_megabytes) + sum(large_write_megabytes))/
                (sum(small_read_reqs) + sum(small_write_reqs) + sum(large_read_reqs) + sum(large_write_reqs)) * 1024 * 1024 io_in_bytes,
                (select extract(minute from (end_interval_time - begin_interval_time)) * 60 +
                        extract(second from (end_interval_time - begin_interval_time))
                   from dba_hist_snapshot s
                  where s.snap_id = h.snap_id) snapshot_in_seconds
           from DBA_HIST_IOSTAT_DETAIL h
          where instance_number = &inst_id 
          group by snap_id
        )
order by snap_id 
/

select bytes/request, bytes/sec
  from (  select (sum(PHYRDS) + sum(PHYWRTS)) request, (sum(PHYBLKRD)+ sum(PHYBLKWRT))*8192 bytes, (sum(READTIM)+sum(WRITETIM))*100 sec
	   from v$filestat
       )
/

