rem Matches : .*
rem Matches : XC.*
rem Matches : ((P|U)0.*|PROD*)

set echo on
set verify off

spool &1/output/02_awr_snapshot_config_&3

prompt Config AWR snapshot setting.

prompt execute dbms_workload_repository.modify_snapshot_settings ( interval => 30, retention => (30*24*60));

begin
    for i in (select 'X' from v$database where cdb = 'NO'
              union
              select 'x' from dual where SYS_CONTEXT('USERENV', 'CON_NAME') = 'CDB$ROOT')
    loop
        dbms_workload_repository.modify_snapshot_settings ( interval => 30, retention => (30*24*60));
    end loop;
end;
/

spool off

exit




