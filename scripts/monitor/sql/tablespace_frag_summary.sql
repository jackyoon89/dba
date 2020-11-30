set line 180
set pagesize 800

accept tblsp prompt 'Tablespace Name: '

select mapping.segment_name,sum((mapping.blocks * tbs.block_size))/1024/1024 size_mb,  count(*)
  from (select file_id, block_id, blocks, segment_name, tablespace_name
          from dba_extents
         where tablespace_name = upper('&&tblsp')
         union
        select file_id, block_id, blocks, 'Free Space', tablespace_name
          from dba_free_space
         where tablespace_name = upper('&&tblsp')
       ) mapping,
       dba_tablespaces tbs
 where tbs.tablespace_name = mapping.tablespace_name
group by mapping.segment_name
having count(*) > 1
order by 3
/
