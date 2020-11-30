col tablespace_name format a20
col file_name       format a48
col autoextensible  format a15
set line 130
set pagesize 24
set heading  on
set feedback off

select tablespace_name,file_name, autoextensible 
  from dba_data_files
 where autoextensible = 'NO'
/
