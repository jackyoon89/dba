#!/bin/ksh
#-------------------------------------------------------------------------------
#File Name      :fndcdba_audit.sh
#Description    :List any DML action on FNDCDBA objects by DBAs
#Modification   : GLPROD-3139 change e-mail group, exclude SELECT/READ only activity from the report
#                 action_name not in ('SELECT')
#
#--------------------------------------------------------------------------------
check_error ()
{
if [ $(grep -c ORA- ${LOGFILE}) -gt 0 ]; then
   mailx -r "${SENDER}" -s "DB_SSGX-ORACLE-`hostname`-${ORACLE_SID}-SSI_Search_Audit::ERROR" ${ERRMAIL} < ${LOGFILE}
   exit 1
fi
}
###########################################
HOME=/home/app/oracle/admin/DBA/crontab/scripts
source /home/resource/oracle/.bash_profile
#ORACLE_HOME=/home/app/oracle/product/db/12.1.0.2.190115; export ORACLE_HOME
PATH=$HOME:$ORACLE_HOME/bin:$PATH; export PATH
TIMESTAMP=`date +%Y%m%d%H%M%S`
SID=""
DEBUG=0
#EMAIL="hpatel@statestreetgx.com"
EMAIL="ITrisk@currenex.com"
SENDER="DBAs@currenex.com"
CCLIST="DBAs@currenex.com,AXu@StateStreet.com"
ERRMAIL="DBAs@currenex.com"

while getopts s:h IN_PUT
do
   case ${IN_PUT} in
      h) echo ""
         echo "$(basename $0) -s oracle_sid"
         exit          ;;
      s) SID="$OPTARG" ;;
     \?) echo ""
         echo "Invalid Option"
         echo "Syntax: $(basename $0) -s oracle_sid"
         exit 1       ;;
   esac
done
if [ "${SID}" = "" ]; then
   echo "Error: Oracle SID is not provided"
   echo "$(basename $0) -s oracle_sid)"
   exit 1
fi
#========================================================================
LOGFILE=/home/app/oracle/admin/DBA/crontab/scripts/log/fndbca_audit_${TIMESTAMP}; export LOGFILE
ORACLE_SID=$SID ; export ORACLE_SID
# Check and get the report header
sqlplus -s '/ as sysdba' <<EOF | grep -v ^$ > ${LOGFILE}
select count(*) from dba_users ;
EOF
check_error

sqlplus -s '/ as sysdba' <<EOF | grep -v ^$ > ${LOGFILE}
set pages 0
select to_char(trunc(sysdate - 1),'mm/dd/yyyy') from dual ;
EOF
check_error

HEADER=$(cat ${LOGFILE})
SUBJECT="O01FDC3 - FNDCDBA Schema Access by DBA Report: "${HEADER}

sqlplus -s '/ as sysdba' <<EOF | grep -v ^$ > ${LOGFILE}
set feedback on
set linesize 300
set pagesize 5000
col OS_USERNAME for a15
col USERNAME for a20
col HOSTNAME for a30
col OWNER for a15
col OBJECT_NAME for a30
col SQL_STMT for a65 wrap
select os_username,username,userhost "HOSTNAME",to_char(timestamp,'mm/dd/yyyy hh24:mi:ss') "TIMESTAMP",
owner,obj_name "OBJECT_NAME",action_name "ACTION",sql_text "SQL_STMT"
from dba_audit_trail where owner='FNDCDBA' and timestamp > trunc(sysdate) - 1 and action_name not in ('SELECT')
and username in (select username from dba_users where profile='CURRENEX_PROFILE') ;
EOF
check_error

#mailx -c hpatel@statestreetgx.com -r "${SENDER}" -s "${SUBJECT}" hpatel@statestreetgx.com < ${LOGFILE}
mailx  -c "${CCLIST}" -r "${SENDER}" -s "${SUBJECT}" ${EMAIL} < ${LOGFILE}
find /home/app/oracle/admin/DBA/crontab/scripts/log/fndbca_audit_* -mtime +90 -exec rm {} \;

