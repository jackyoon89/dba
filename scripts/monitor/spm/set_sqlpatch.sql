declare
   v_sql CLOB;
begin
   select sql_text into v_sql from dba_hist_sqltext where sql_id='&sql_id';
   sys.dbms_sqldiag_internal.i_create_patch(
      sql_text  => v_sql,
      hint_text => '&hint',
      name      => '&patch_name');
end;
/
