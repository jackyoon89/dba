rem
rem File Name : db_user_list.sql
rem 

set pagesize 500
set line 180
set verify off
set heading off
set feedback off

select '<tr><td>'||user_id||'</td><td>'||username||'</td><td>'||account_status||'</td><td>'||nvl(to_char(lock_date),'.')||'</td><td>'||nvl(to_char(expiry_date),'.')||'</td><td>'||default_tablespace||'</td><td>'||temporary_tablespace||'</td><td>'||created||'</td><td>'||profile||'</td></tr>'
  from dba_users 
order by account_status,user_id desc
/

exit

