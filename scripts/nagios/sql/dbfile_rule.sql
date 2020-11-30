rem 
rem In this script, we treat freespace as "actual freespace" + "total extensible space - occpuied space".
rem

set line 180
set heading off
set verify off
set feedback off
col tablespace_name format a30

select d.tablespace_name||' '||ListAgg(file_id,',') within group(order by file_id )
  from dba_data_files d, dba_tablespaces t
where d.tablespace_name = t.tablespace_name
  and (( round(maxbytes/1024/1024/1024) < &&1 and maxbytes <> 0 )
   or ( round(bytes/1024/1024/1024) < &&1 and autoextensible = 'NO' )
   or ( t.bigfile = 'NO' and round(bytes/1024/1024/1024) > &&1 and autoextensible = 'YES')
   or ( t.bigfile = 'NO' and round(maxbytes/1024/1024/1024) > &&1 and autoextensible = 'YES'))
group by d.tablespace_name
order by d.tablespace_name
/

exit

