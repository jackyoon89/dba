    select sql_id,count(*)
      from v$sql
    group by sql_id
   having count(*) > 2
order by 2
/
