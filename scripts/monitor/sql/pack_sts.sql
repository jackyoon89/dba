whenever sqlerror exit failure;

set serverout on


prompt ------> Create Staging table and Pack Sql Tuning Set
prompt



accept schema_name  prompt 'Staging Schema Name: ';
accept table_name   prompt 'Staging Table Name: ';
accept sqlset_owner prompt 'Sqlset Owner: ';
accept sqlset_name  prompt 'Sqlset Name: ';

begin
    dbms_sqltune.create_stgtab_sqlset (
        schema_name => upper('&schema_name'),
        table_name => upper('&table_name'));
end;
/



begin
    dbms_sqltune.pack_stgtab_sqlset (
        sqlset_owner => upper('&sqlset_owner'),
        sqlset_name  => upper('&sqlset_name'),
        staging_schema_owner => upper('&schema_name'),
        staging_table_name   => upper('&table_name'));
end;
/


prompt >> Please export the &schema_name..&table_name and transport the dump file to your destination server.
prompt >>
prompt >> expdp &schema_name directory=EXPDP_DIR dumpfile=&table_name..dmp tables=&table_name
prompt >>
