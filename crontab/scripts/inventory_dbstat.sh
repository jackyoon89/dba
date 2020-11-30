#-------------------------------------------------------------------------------
#File Name      :inventory_dbstat.sh
#Description    :This script will checks running instance and create
#                report of database status and upload to inventory site   
#Owner          :hpatel@statestreetgx.com
#Note           :some other report functionaliy are commented to be use in future 
#-------------------------------------------------------------------------------

#!/bin/ksh
pgrep -lf ora_smon |
 while read p a; do
  printf "%-10s:%s\n" $a `ls -l /proc/$p/exe | awk -F'>' '{ print $2 }' | sed 's/\/bin\/oracle$//' | sort | uniq` >> /tmp/all_db_info
  sed 's/ora_smon_//' /tmp/all_db_info > /tmp/temp.txt
  mv /tmp/temp.txt /tmp/all_db_info
done
# Set this in accordance with the platform
ORATAB=/tmp/all_db_info
if [ ! $ORATAB ] ; then
  echo "$ORATAB not found"
  exit 1;
fi

export LOG_HOME=/tmp
export HOST_NAME=`hostname`
export LOG_NAME=all_databases_status_${HOST_NAME}_`date +%m%d%Y%H%M`.csv
export DATE=$(date +%Y-%m-%d)
export LOG_NAME1=all_users_status_${HOST_NAME}_`date +%m%d%Y%H%M`.csv
export LOG_NAME2=all_db_registry_${HOST_NAME}_`date +%m%d%Y%H%M`.csv
export msg_out="$LOG_HOME/mail_out.$HOSTNAME.${DATE}"
export msg_out1="$LOG_HOME/mail_out1.${DATE}"
export msg_out2="$LOG_HOME/mail_out2.${DATE}"
export email_add_sucess=

echo "CREATED,DBID,DBROLE,DBNAME,HOSTNAME,VERSION,DB_STATUS,DB_CLUSTER,DB_CONTAINER,DBMS" >> $LOG_HOME/$LOG_NAME
#echo "DB_NAME,USERNAME,ACCOUNT_STATUS,LOCK_DATE,CREATED,EXPIRY_DATE,PROFILE" >> $LOG_HOME/$LOG_NAME1 
#echo "DB_NAME,HOSTNAME,ACTION_TIME,ACTION,VERSION,COMMENTS" >> $LOG_HOME/$LOG_NAME2

# Following loop brings up 'Database instances'
#
cat $ORATAB | while read LINE
do
case $LINE in
  \#*)                ;;        #comment-line in oratab
  *)
  ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
  if [ "$ORACLE_SID" = '*' ] ; then
    # same as NULL SID - ignore this entry
    ORACLE_SID=""
    continue
  fi
      ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
      export ORACLE_HOME 
      export ORACLE_SID

    mdbversion=`$ORACLE_HOME/bin/sqlplus -S / as sysdba  <<EOF
      set heading off feedback off verify off
      SELECT substr(version,1,2) as ver from v\\$instance;
      exit
EOF
      `
    mdbstatus=""
      mdbstatus=`$ORACLE_HOME/bin/sqlplus -S / as sysdba <<EOF
      set heading off feedback off verify off
      SELECT status from v\\$instance;
      exit
EOF
      `
      
      if [ $mdbversion -eq 12 ] ; then
    mpdbcnt=`$ORACLE_HOME/bin/sqlplus -S / as sysdba <<EOF
      set heading off feedback off verify off
      select count(*) from v\\$pdbs;
      exit
EOF
      `
      fi

###for version 12 and have pdbs

oracle_rep1()
{
$ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
set heading off feedback off verify off
set line 200 
set pagesize 5000
select created
||','||dbid
||','||dbroll
||','||pdb_name
||','||hostname
||','||ora_version
||','||db_status
||','||db_cluster
||','||db_container
||','||'Oracle'
from
(select d.created,
 d.dbid,
 d.database_role as dbroll,
 p.name as pdb_name, 
 i.host_name as hostname,
 i.version as ora_version,
 i.status as db_status,
 v.value as db_cluster,
 d.cdb as db_container
 from v\$database d, v\$instance i,  v\$parameter v , v\$pdbs p
 where v.name='cluster_database' and p.name in (select name from v\$pdbs where name not like '%SEED'));
exit
EOF
}

### for version 12 and no pdbs

oracle_rep2()
{
$ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
set heading off feedback off verify off
set line 200 
set pagesize 5000
select created
||','||dbid
||','||dbroll
||','||dbname
||','||hostname
||','||ora_version
||','||db_status
||','||db_cluster
||','||db_container
||','||'Oracle'
from
(select d.created,
 d.dbid,
 d.database_role as dbroll,
 d.name as dbname,
 i.host_name as hostname,
 i.version as ora_version,
 i.status as db_status,
 v.value as db_cluster,
 d.cdb as db_container
 from v\$database d, v\$instance i,  v\$parameter v
 where v.name='cluster_database');
exit
EOF
}

### for version 11 or below

oracle_rep()
{
$ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
set heading off feedback off verify off
set line 200 
set pagesize 5000
select created
||','||dbid
||','||dbroll
||','||dbname
||','||hostname
||','||ora_version
||','||db_status
||','||db_cluster
||','||'FALSE'
||','||'Oracle'
from
(select d.created,
d.dbid,
d.database_role as dbroll,
d.name as dbname,
i.host_name as hostname,
i.version as ora_version,
i.status as db_status,
v.value as db_cluster
from v\$database d, v\$instance i,  v\$parameter v where v.name='cluster_database');
exit
EOF
}

oracle_users()
{
$ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
set feedback off verify off
set heading off
SET LINESIZE 200
set pagesize 50000
set echo off
COLUMN spid FORMAT A10
COLUMN db_name FORMAT A15
COLUMN sid FORMAT 99999
COLUMN type FORMAT A10
COLUMN time FORMAT A22 heading "LOGON TIME"
COLUMN username FORMAT A25
COLUMN account_status FORMAT A20
COLUMN profile FORMAT A30
COLUMN terminal FORMAT A20
COLUMN program FORMAT A45
select created
||','||db_name
||','||host_name
||','||username
||','||account_status
||','||lock_date
||','||created
||','||expiry_date
||','||profile
from
( SELECT sys_context('USERENV', 'DB_NAME') db_name,sys_context('USERENV','HOST') host_name,
  username,account_status,lock_date, created, expiry_date,profile
  FROM dba_users) ;
exit
EOF
}

oracle_reg()
{
$ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
set feedback off verify off
set heading off
set lines 250 
set pagesize 5000
col comments for a65 wrap
set heading off
ALTER SESSION SET nls_timestamp_format='YYYY-MM-DD HH24:MI';
select db_name
||','||host_name
||','||action_time
||','||action
||','||version
||','||comments
from
( SELECT sys_context('USERENV', 'DB_NAME') db_name,sys_context('USERENV','HOST') host_name,
  action_time,action,version,comments from dba_registry_history ORDER BY 1 );
exit
EOF
}
if [ $mdbstatus = "OPEN" ]; then 
   if [ $mdbversion -eq 11 ] ; then
      oracle_rep >> $LOG_HOME/$LOG_NAME
 #     oracle_users >> $LOG_HOME/$LOG_NAME1
 #     oracle_reg >> $LOG_HOME/$LOG_NAME2
   else 
      if [ $mdbversion -eq 12 ] && [ $mpdbcnt -eq 0 ] ; then
          oracle_rep2 >> $LOG_HOME/$LOG_NAME
  #        oracle_users >> $LOG_HOME/$LOG_NAME1
  #        oracle_reg >> $LOG_HOME/$LOG_NAME2
      else 
          oracle_rep1 >> $LOG_HOME/$LOG_NAME
   #       oracle_users >> $LOG_HOME/$LOG_NAME1
   #       oracle_reg >> $LOG_HOME/$LOG_NAME2
      fi
   fi
else
  oracle_rep >> $LOG_HOME/$LOG_NAME
fi
  ;;
esac
done
rm /tmp/all_db_info
find /tmp/all_*.csv -mtime +2 -exec rm {} \;
 cat $LOG_HOME/$LOG_NAME > $msg_out
 #cat $LOG_HOME/$LOG_NAME1 > $msg_out1
 #cat $LOG_HOME/$LOG_NAME2 > $msg_out2
  #mailx -s "ORACLE ALL DATABASES STATUS REPORT " $email_add_sucess < $msg_out
  #mailx -s "ORACLE ALL DATABASES USERS STATUS REPORT " $email_add_sucess < $msg_out1
  #mailx -s "ORACLE ALL DATABASES PATCH STATUS REPORT " $email_add_sucess < $msg_out2

# below script provided by Chris Ruddy to upload the report to inventory site
. /opt/syseng/share/common/identifier.sh
curl -F "dbs=<$LOG_HOME/$LOG_NAME" "http://syseng/syseng/autoinventory/db/db.php$identifier"


