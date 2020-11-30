whenever sqlerror continue;

set pagesize 10000
set line 250
set long 10000
accept tab_owner prompt 'Table Owner[Current User]: '
accept tab_name  prompt 'Table Name: '


select dbms_metadata.get_ddl('INDEX', index_name, nvl(upper('&tab_owner'),SYS_CONTEXT ('USERENV', 'SESSION_USER')))
  from dba_indexes
 where table_name = upper('&&tab_name')
order by index_name
/
