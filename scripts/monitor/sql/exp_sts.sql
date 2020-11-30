set line 180
col DESCRIPTION format a30
col OWNER format a20

select * from dba_sqlset;

accept tname         prompt 'Staging Table Name:';
accept schema        prompt 'Schema Name:';
accept sqlset_name   prompt 'SqlSet Name:';
accept sqlset_owner  prompt 'SqlSet owner:';


BEGIN
  DBMS_SQLTUNE.CREATE_STGTAB_SQLSET ( 
    table_name  => upper('&tname'),
    schema_name => upper('&schema'));
END;
/


BEGIN
  DBMS_SQLTUNE.PACK_STGTAB_SQLSET (      
    sqlset_name         => upper('&sqlset_name'),
    sqlset_owner        => upper('&sqlset_owner'),
    staging_table_name  => upper('&tname'),
    staging_schema_owner=> upper('&schema'));
END;
/ 
