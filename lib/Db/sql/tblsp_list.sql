col tablespace_name format a30
set line 80
set heading off
set feedback off
set pagesize 500

select tablespace_name
  from dba_tablespaces
 where contents <> 'TEMPORARY'
/

exit

