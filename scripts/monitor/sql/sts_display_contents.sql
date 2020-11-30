whenever sqlerror exit failure;

prompt -------> Existing SQL Tuning Sets
prompt

set line 180
col name format a25
col description format a30

select id, name, owner, last_modified, statement_count from dba_sqlset;


accept sts_name prompt 'STS Name: ';

set line 180
set pagesize 80
col sql_text format a80

select sql_id, sql_text from table(dbms_sqltune.select_sqlset('&sts_name'));

