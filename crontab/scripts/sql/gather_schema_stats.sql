SET PAGESIZE 0
SET LINESIZE 180
SET ECHO ON
SET SERVEROUT ON
SET TIMING ON

spool &1/log/gather_schema_stats.log

begin
    for i in ( select username from dba_users where username in ('IPS','DBMIGRATION','WHITNEY','IPS_REPORT','WMX','READONLY','EFXQUANT','CALYPSO','PAM'))
    loop
        dbms_output.put_line('Schema '||i.username||' analyzed : ');

        dbms_stats.gather_schema_stats(i.username, granularity => 'ALL', degree => 16, estimate_percent=>20, cascade => true, method_opt => 'FOR ALL COLUMNS SIZE SKEWONLY');

    end loop;
end;
/

spool off

exit
