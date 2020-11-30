select object_type, owner||'.'||object_name from dba_objects where object_name = upper('&1')
/
