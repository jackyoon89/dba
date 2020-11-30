set line 180
set pagesize 80
col column_name format a30
col index_name format a40

accept owner prompt "Enter Schema owner: "
accept tab   prompt "Enter Tablename: "

select distinct i.index_name,i.uniqueness,i.index_type,c.column_name,c.column_position, i.visibility, i.compression
 from dba_ind_columns c, dba_indexes i
where i.owner = upper('&owner')
  and i.table_name = upper('&tab')
  and i.index_name = c.index_name
order by i.index_name,c.column_position
/

undefine owner tab

