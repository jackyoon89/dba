break on dfo_no on tq_io on server_type
select  tq_id, server_type,process,num_rows,bytes,waits
from v$pq_tqstat
order by dfo_number, tq_id,decode(substr(server_type,1,4),'Rang',1,'Prod',2,'Cons',3),process
/

exit
