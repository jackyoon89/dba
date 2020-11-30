set line 180
col owner format a30
col segment_name format a30
 
select OWNER,SEGMENT_NAME, TABLESPACE_NAME from dba_extents
    where file_id = &1 
    and &2 between block_id and block_id + blocks;

