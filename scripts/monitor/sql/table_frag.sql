set line 180

accept username prompt 'User Name: '

select owner, table_name,round((blocks*8),2) "size (kb)" ,
   round((num_rows*avg_row_len/1024),2) "actual_data (kb)",
   (round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "wasted_space (kb)"
from
   dba_tables
where username = upper('&username')
  and (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 5
/
