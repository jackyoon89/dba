set serverout on 
set numformat 9,999,999,999.99

set pagesize 800
set line 180

accept schema prompt "Please provide schema name: "
accept table prompt "Please provide table name(default: ALL): "

col tablespace_name format a15
col table_name format a30
col index_name format a30
break on table_name skip page on table_space on index_space

select t.table_name, t.tablespace_name table_space, i.index_name, i.tablespace_name index_space, i.compression, i.status, i.visibility
  from dba_tables t, dba_indexes i
 where t.table_name = i.table_name
   and t.owner = upper('&schema')
   and t.table_name = upper(nvl('&table',t.table_name))
order by t.table_name, t.tablespace_name, i.tablespace_name, i.index_name
/

undefine schema
undefine table

