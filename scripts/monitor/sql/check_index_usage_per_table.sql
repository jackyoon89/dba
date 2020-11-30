
set line 180
set pagesize 80
col table_name format a30
col c1 heading 'Object|Name' format a30
col c2 heading 'Operation' format a15
col c3 heading 'Option' format a15
col c4 heading 'Index|Usage|Count' format 999,999

break on c1 skip 2
break on c2 skip 2

select i.table_name, h.*
  from dba_indexes i,
       (select p.object_name c1, p.operation c2, p.options c3, count(1) c4
          from dba_hist_sql_plan p, dba_hist_sqlstat s
         where p.object_owner <> 'SYS'
           and p.operation like '%INDEX%'
           and p.sql_id = s.sql_id
         group by p.object_name, p.operation, p.options) h
where h.c1 = i.index_name
  and i.table_name = upper('&1')
order by 5
/

