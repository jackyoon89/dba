set line 180
col owner format a30
col object_name format a30

select object_type, owner, object_name
  from dba_objects 
 where object_name = upper('&obj')
/
