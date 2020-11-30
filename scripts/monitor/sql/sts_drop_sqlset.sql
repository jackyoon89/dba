whenever sqlerror exit failure;

prompt -------> Drop SQL Tuning Sets
prompt

set line 180
col name format a35
col description format a30

select id, name, owner, last_modified, statement_count from dba_sqlset;


accept sts_name prompt 'STS Name: ';

begin
    dbms_sqltune.drop_sqlset(sqlset_name => '&sts_name');
end;
/

