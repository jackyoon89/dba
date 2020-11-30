col TABLESPACE_NAME format a20
col FREE_SPACE format 999,999.99
col TOTAL_SPACE format 999,999.99
set pagesize 24
set line 80
set heading on
set verify off
set feedback off

select a.tablespace_name,
       round(a.bytes/1024/1024,2) FREE_SPACE,
       round(b.bytes/1024/1024,2) TOTAL_SPACE,
       round(((b.bytes-a.bytes)/b.bytes)*100,2) "%OCCUPIED"
  from ( select tablespace_name,sum(bytes) bytes
           from dba_free_space
          group by tablespace_name ) a,
       ( select tablespace_name,sum(bytes) bytes
           from dba_data_files
          group by tablespace_name ) b
 where a.tablespace_name = b.tablespace_name
   and a.tablespace_name <> 'SYSAUX' 
   and round(((b.bytes-a.bytes)/b.bytes)*100,2) >= &1
 order by 4
/

exit
