set line 180
col column_name format a45
col index_name format a40

select distinct i.index_name,i.index_type,c.column_name,c.column_position 
from dba_ind_columns c, dba_indexes i
where i.owner = upper('&1')
  and i.table_name = upper('&2')
  and i.index_name = c.index_name
order by i.index_name,c.column_position
/

