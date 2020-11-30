whenever sqlerror continue;

set pagesize 10000
set long 10000
accept obj_owner prompt 'Object Owner[Current User]: '
accept obj_type  prompt 'Object Type[TABLE]: '
accept obj_name  prompt 'Object Name: '

select dbms_metadata.get_ddl(nvl(upper('&obj_type'),'TABLE'), upper('&obj_name'), nvl(upper('&obj_owner'),SYS_CONTEXT ('USERENV', 'SESSION_USER'))) 
from dual;

