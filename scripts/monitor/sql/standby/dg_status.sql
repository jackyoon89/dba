select inst_id, facility, timestamp, severity, message
from gv$dataguard_status
where severity not in ('Warning','Informational','Control')
  and timestamp > (sysdate - (&mins_ago/1440));

