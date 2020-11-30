whenever sqlerror exit failure;

set serverout on


prompt ------> Create SQL Tuning Set(STS) from Cursor Cache
prompt

accept sts_name prompt 'Tuning Set Name: ';
accept sts_desc prompt 'Description: ';

begin
  dbms_sqltune.create_sqlset (
    sqlset_name  => '&&sts_name',
    description  => '&sts_desc');
end;
/



prompt ------>  Load the SQL Tuning Set from Cursor Cache.
prompt

declare
  l_cursor  dbms_sqltune.sqlset_cursor;
begin
  open l_cursor for
    select value(p)
    from   table (dbms_sqltune.select_cursor_cache()) p;

  dbms_sqltune.load_sqlset (
    sqlset_name     => '&&sts_name',
    populate_cursor => l_cursor);
END;
/





