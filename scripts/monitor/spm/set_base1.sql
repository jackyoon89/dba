
var cnt number;

exec :cnt := dbms_spm.load_plans_from_cursor_cache('&sql_id');

print :cnt

