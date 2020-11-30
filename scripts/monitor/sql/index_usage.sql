select object_name,count(*)
from dba_hist_sql_plan
where object_name like '%'||upper('&&1')||'%'
and object_name <> upper('&&1')
group by object_name
/
