set line 180
set pagesize 80
col owner format a10
col name format a30
col description format a50

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select id, owner, name, description, statement_count, created, last_modified from dba_sqlset
order by id
/
