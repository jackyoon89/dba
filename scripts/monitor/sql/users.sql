set line 180
set pagesize 80
col username format a30
col account_status format a30
col profile format a30

select username, account_status, profile 
from dba_users
/
