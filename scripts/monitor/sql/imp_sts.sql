
accept tname         prompt 'Staging Table Name:';
accept schema        prompt 'Schema Name:';
accept sqlset_name   prompt 'SqlSet Name:';
accept sqlset_owner  prompt 'SqlSet owner:';


BEGIN
  DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET (      
    sqlset_name         => upper('&sqlset_name'),
    sqlset_owner        => upper('&sqlset_owner'),
    replace             => TRUE,
    staging_table_name  => upper('&tname'),
    staging_schema_owner=> upper('&schema'));
END;
/ 



set line 180
col DESCRIPTION format a30
col OWNER format a20

select * from dba_sqlset;
