col table_name format a25
col index_name format a25
col status     format a10
col owner      format a10
set line 110
set feedback   off

select owner,table_name,index_name,status 
  from dba_indexes
 where status = 'UNUSABLE';
/
