rem Matches : .*
rem Matches : XC.*
rem Matches : ((P|U)0.*|PROD*)

set echo on
set verify off

spool &1/output/02_expdp_dir_&3

prompt Creating Directory object EXPDP_DIR as '/oracle/recovery_area/EXPORTS/&3'

drop directory expdp_dir
/

create directory expdp_dir as '/oracle/recovery_area/EXPORTS/&3'
/

prompt /oracle/recovery_area/EXPORTS/&3
!mkdir -p /oracle/recovery_area/EXPORTS/&3 2>/dev/null

prompt /oracle/recovery_area/&2/autobackup
!mkdir -p /oracle/recovery_area/&2/autobackup 2>/dev/null

spool off

exit




