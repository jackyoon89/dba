whenever sqlerror exit failure;

set serverout on


prompt >> Note: Please import staging table for Sql Tuning Set before you start.
prompt >>


prompt ------> Unpack Sql Tuning Set
prompt



accept schema_name  prompt 'Staging Schema Name: ';
accept table_name   prompt 'Staging Table Name: ';
accept sqlset_owner prompt 'Sqlset Owner: ';
accept sqlset_name  prompt 'Sqlset Name: ';



begin
    dbms_sqltune.unpack_stgtab_sqlset (
        sqlset_owner => upper('&sqlset_owner'),
        sqlset_name  => upper('&sqlset_name'),
        replace      => true,
        staging_schema_owner => upper('&schema_name'),
        staging_table_name   => upper('&table_name'));
end;
/


