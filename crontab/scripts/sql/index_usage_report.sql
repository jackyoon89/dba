rem
rem File Name : index_usage_report.sql
rem 

set pagesize 0
set line 180
set verify off
set heading off
set feedback off


select '<tr><td>'||i.owner||'</td><td>'||i.table_name||'</td><td>'||i.index_name||'</td><td>'||nvl(u.usage,0)||'</td></tr>'
  from dba_indexes i, ( select owner, object_name index_name, count(*) usage
                          from crontab.index_monitoring_usage
                         group by owner, object_name ) u
 where u.index_name(+) = i.index_name
   and i.owner in ( 'WHITNEY','IPS','IPS_OWNER')
 order by i.owner,i.table_name,nvl(u.usage,0) desc
/


truncate table crontab.index_monitoring_usage
/

exit
