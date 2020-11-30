rem
rem File Name : audit_trail_report.sql
rem 

set pagesize 50000
set line 32767
set verify off
set heading off
set feedback off


insert into system.audit_history
select *
from dba_audit_trail
where os_username not in ('apps','apache','efxapps')
  and username not in ('CRONTAB','C##ADMIN','DBSNMP','SYSMAN','PUBLIC','OGG')
/

select to_char(TIMESTAMP,'DD-MON-YY HH24:MI:SS')||','||OS_USERNAME||'@'||USERHOST||','||USERNAME||','||ACTION_NAME||','||OBJ_NAME||','||decode(RETURNCODE,0,'SUCCEED',
                      1005,'Null password given; login denied',
                      1017,'Invalid username/password; login denied',
                      28000,'The account is locked')||','||COMMENT_TEXT
  from system.audit_history
 where timestamp >= sysdate - 7
   and os_username not in ('apps','apache','efxapps')
order by TIMESTAMP DESC
/

rem delete from system.audit_history
rem where timestamp < add_months(sysdate, -24)
rem /

rem execute sys.truncate_audit_table
rem /

truncate table sys.aud$
/

exit
