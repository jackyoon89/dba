#!/bin/ksh
#-------------------------------------------------------------------------------
#File Name      :gldba_oracle_ssi_audit.sh
#Description    :Sending Notification for FDA enable tables for SSI schema
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
TIMESTAMP=`date +%Y%m%d`
SID=""
DEBUG=0
#EMAIL="DBAs@statestreet.com"
EMAIL="ITrisk@currenex.com"
SENDER="DBAs@currenex.com"
CCLIST="DBAs@currenex.com,JShaffer@globallink.com,ITrisk@currenex.com"
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

LOGFILE=/home/app/oracle/admin/DBA/crontab/scripts/log/ssi_audit_${TIMESTAMP}; export LOGFILE

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
SUBJECT="DBA Modifications in SSI Search : "${HEADER}

sqlplus -s '/ as sysdba' <<EOF | grep -v ^$ > ${LOGFILE}
set feedback on
set pagesize 200
col OS_USERNAME for a15
col USERNAME for a20
col HOSTNAME for a30
col OWNER for a15
col OBJECT_NAME for a30
col SQL_STMT for a65 wrap
col TABLE_NOT_FDA_ENABLED for a35
col TABLE_FDA_ENABLED for a35
set linesize 200

select os_username,username,userhost "HOSTNAME",to_char(timestamp,'mm/dd/yyyy hh24:mi:ss') "TIMESTAMP",
owner,obj_name "OBJECT_NAME",action_name "ACTION"
from dba_audit_trail where owner='SSIOWNER' and timestamp > trunc(sysdate) - 1
and username in (select username from dba_users where profile='CURRENEX_PROFILE') ;

select owner,object_name as "TABLE_NOT_FDA_ENABLED" from dba_objects where owner='SSIOWNER' and object_name not in (select table_name from DBA_FLASHBACK_ARCHIVE_tables) and object_type='TABLE' and object_name not like '%FBA%';

select owner_name as "OWNER",table_name as "TABLE_FDA_ENABLED",status from DBA_FLASHBACK_ARCHIVE_tables where owner_name='SSIOWNER';
EOF
check_error
mailx  -c "${CCLIST}" -r "${SENDER}" -s "${SUBJECT}" ${EMAIL} < ${LOGFILE}

find /home/app/oracle/admin/DBA/crontab/scripts/log/ssi_audit_* -mtime +60 -exec rm {} \;

