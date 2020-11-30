declare
  my_plans pls_integer;
begin
    my_plans := dbms_spm.load_plans_from_cursor_cache( sql_id => 'gmktp5bcy3k8r');
end;
/
