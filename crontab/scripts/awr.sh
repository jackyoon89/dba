# Written by Ajay Jain
. /home/oracle/FXRPT.env
DATE=`date +%Y_%b_%d-%H-%M`
LOGFILE=/home/oracle/admin/jaina/scripts/log/${ORACLE_SID}_AWR_$DATE.html
#EMAIL_ID="BIMgmt@currenex.com ajain@currenex.com"
EMAIL_ID="ajain@currenex.com"


sqlplus -s "/as sysdba" > $LOGFILE <<EOF
set serveroutput on size 1000000
set linesize 500 pagesize 999 trimspool on
declare
  V_dbid number;
  V_inst_id number;
  V_last_snap_id number;
  V_output clob;
begin
  select dbid into V_dbid from v\$database;
  select instance_number into V_inst_id from v\$instance;
  select max(snap_id) into V_last_snap_id from dba_hist_snapshot;
  
  -- 2 Hours of sanpshot period from current time
  for rec in (select * from table(dbms_workload_repository.awr_report_html(V_dbid,V_inst_id, V_last_snap_id - 2, V_last_snap_id)))
   loop
     dbms_output.put_line(rec.output);
   end loop;
end;
/
EOF

echo " $ORACLE_SID : AWR report  created at $DATE" | mutt -s "$ORACLE_SID : $DATE AWR Report  " -a $LOGFILE $EMAIL_ID
rm -f $LOGFILE
