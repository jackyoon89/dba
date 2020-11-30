#!/bin/ksh
#-------------------------------------------------------------------------------
#File Name      : quartzjob.sh
#Description    : DB Quartz job for RFS/RFS MV/AOR/AEE GLUAT-6285
#Modification   : h.patel - do not email if there is no output of sql (no rows selected)20191003
#
#--------------------------------------------------------------------------------
check_error ()
{
if [ $(grep -c ORA- ${LOGFILE}) -gt 0 ]; then
   mailx -r "${SENDER}" -s "DB_SSGX-ORACLE-`hostname`-${ORACLE_SID}-quartz_job::ERROR" ${ERRMAIL} < ${LOGFILE}
   exit 1
fi
}
###########################################
source /home/resource/oracle/.bash_profile 

HOME=/home/app/oracle/admin/DBA/crontab/scripts
#ORACLE_HOME=/home/app/oracle/product/db/12.1.0.2.190115; export ORACLE_HOME
PATH=$HOME:$ORACLE_HOME/bin:$PATH; export PATH
TIMESTAMP=`date +%Y%m%d%H%M%S`
SID=""
DEBUG=0
EMAIL="fxconnectdev@StateStreet.com,JLTrickett@StateStreet.com,MNIRMAL1@StateStreet.com"
SENDER="DBAs@currenex.com"
CCLIST="DBAs@currenex.com"
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
LOGFILE=/home/app/oracle/admin/DBA/crontab/scripts/log/quartzjob_${TIMESTAMP}; export LOGFILE
ORACLE_SID=$SID ; export ORACLE_SID
# Check and get the report header
sqlplus -s '/ as sysdba' <<EOF | grep -v ^$ > ${LOGFILE}
set pages 0
select TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') from dual ;
EOF
check_error

HEADER=$(cat ${LOGFILE})
SUBJECT="DB Quartz job for RFS/RFS MV/AOR/AEE Report : U01FXC : "${HEADER}

sqlplus -s '/ as sysdba' <<EOF | grep -v ^$ > ${LOGFILE}
set feedback off
alter session set container=U01FXC ;
set feedback on
set linesize 300
set pagesize 5000
col buyinstitution for a30
col banks for a20
#col current_timestamp for a30
select * from 
(
select session_id, buyinstitution, banks, current_timestamp - modified "current_timestamp",
trunc(1000 * (extract(second from current_timestamp - modified)
+ 60 * (extract(minute from current_timestamp - modified)
+ 60 * (extract(hour from current_timestamp - modified)
+ 24 * (extract(day from current_timestamp - modified) ))))) as milliseconds
from fxcowner.trade_sessions
where sessiontype in (7,0,2,3) -- RFS, Portfolio AEE, CP AEE
and status in (70, 71)
and modified > sysdate - 1
)
where milliseconds > 60*1000*10 ;

EOF
check_error

word=$(cat ${LOGFILE})
if [[ $word  == 'no rows selected' ]]; then
echo ""
else
  mailx  -c "${CCLIST}" -r "${SENDER}" -s "${SUBJECT}" ${EMAIL} < ${LOGFILE}
fi

#mailx -c hpatel@statestreetgx.com -r "${SENDER}" -s "${SUBJECT}" hpatel@statestreetgx.com < ${LOGFILE}
#mailx  -c "${CCLIST}" -r "${SENDER}" -s "${SUBJECT}" ${EMAIL} < ${LOGFILE}
find /home/app/oracle/admin/DBA/crontab/scripts/log/quartzjob_* -mtime +30 -exec rm {} \;

