rem 
rem Temp Space usage percentage
rem

select (s.tot_used_blocks/f.total_blocks)*100 as pctused
  from (select sum(used_blocks) tot_used_blocks
          from v$sort_segment
         where tablespace_name = 'TEMP') s, 
       (select sum(blocks) total_blocks
          from dba_temp_files
         where tablespace_name = 'TEMP') f
/
