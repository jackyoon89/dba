var cnt number;

exec :cnt := dbms_spm.load_plans_from_cursor_cache('&sql_id', to_number('&plan_hash_value'));

print :cnt
