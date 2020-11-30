set line 100
set heading off
set feedback off
set verify off
col file_name format a80

select file_name
  from dba_data_files
 where tablespace_name = upper('&1')
 order by file_id
/

exit

