set line 180
set pagesize 800

accept tblsp prompt 'Tablespace Name: '

select mapping.file_id, mapping.block_id, (mapping.blocks * tbs.block_size)/1024 size_kb, mapping.segment_name
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
 order by mapping.file_id, mapping.block_id;

