rem Matches : .*
rem Matches : XC.*
rem Matches : ((P|U)0.*|PROD*)

set serverout on
set verify off

prompt "Database : &2"

spool &1/output/01_audit_mgnt_&2


REM
REM 1. Clean up in case if there are any pending configuration
REM

exec  DBMS_AUDIT_MGMT.drop_purge_job( audit_trail_purge_name     => 'PURGE_ALL_AUDIT_TRAILS'); 
exec  DBMS_SCHEDULER.DROP_JOB('SET_LAST_ARCHIVE_TIMESTAMP_JOB');
exec  DBMS_SCHEDULER.DROP_JOB('PURGE_ALL_AUDIT_TRAILS');
delete from DAM_CLEANUP_JOBS$;
commit;

rem 
rem 2. Sets up the audit management infrastructure and sets a default cleanup interval for audit trail records/files
rem
COLUMN parameter_name FORMAT A30 
COLUMN parameter_value FORMAT A20 
COLUMN audit_trail FORMAT A20

SELECT * FROM dba_audit_mgmt_config_params
/

DECLARE
    already_initialized exception;
    pragma exception_init( already_initialized, -46263 ); 
BEGIN
  DBMS_AUDIT_MGMT.init_cleanup( audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, default_cleanup_interval => 24 /* hours */);
  DBMS_AUDIT_MGMT.init_cleanup( audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD, default_cleanup_interval => 24 /* hours */);
  DBMS_AUDIT_MGMT.init_cleanup( audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS, default_cleanup_interval => 24 /* hours */);
  DBMS_AUDIT_MGMT.init_cleanup( audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML, default_cleanup_interval => 24 /* hours */);
exception 
when already_initialized then
    dbms_output.put_line('Already initialized.');
when others then
    dbms_output.put_line('Error Code is '||SQLCODE);
    dbms_output.put_line('Error Message is '||sqlerrm);
END;
/

SELECT * FROM dba_audit_mgmt_config_params
/






rem 
rem 3. Create SET_LAST_ARCHIVE_TIMESTAMP Procedure 
rem

create or replace procedure sys.set_last_archive_timestamp
is
begin
   
    dbms_audit_mgmt.set_last_archive_timestamp(
        audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
        last_archive_time => SYSTIMESTAMP-180);

    dbms_audit_mgmt.set_last_archive_timestamp(
        audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
        last_archive_time => SYSTIMESTAMP-180);


    for i in (select inst_id from gv$instance)
    loop
        dbms_audit_mgmt.set_last_archive_timestamp(
            audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
            rac_instance_number => i.inst_id,
            last_archive_time => SYSTIMESTAMP-7);

        dbms_audit_mgmt.set_last_archive_timestamp(
            audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
            rac_instance_number => i.inst_id,
            last_archive_time => SYSTIMESTAMP-7);

    end loop;
end;
/


execute sys.set_last_archive_timestamp;

COLUMN audit_trail FORMAT A20 
COLUMN last_archive_ts FORMAT A40
set line 180

SELECT AUDIT_TRAIL, RAC_INSTANCE, LAST_ARCHIVE_TS, DATABASE_ID, CONTAINER_GUID FROM dba_audit_mgmt_last_arch_ts;




rem
rem 4. Create scheduler job for that calls the stored procedure every day.
rem 

DECLARE
    already_exists exception;
    pragma exception_init( already_exists, -27477); 
BEGIN   

  DBMS_AUDIT_MGMT.create_purge_job(     
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,     
    audit_trail_purge_interval => 24 /* hours */,       
    audit_trail_purge_name     => 'PURGE_ALL_AUDIT_TRAILS',     
    use_last_arch_timestamp    => TRUE); 

exception 
when already_exists then
    dbms_output.put_line('Purge job is already exists.');
END; 
/


BEGIN 
  DBMS_SCHEDULER.SET_ATTRIBUTE (    
    name           =>   'PURGE_ALL_AUDIT_TRAILS',    
    attribute      =>   'START_DATE',    
    value          =>   '24-DEC-2019 01:00:00 AM'); 
END; 
/ 

select job_action, START_DATE, REPEAT_INTERVAL 
  from dba_scheduler_jobs       
 WHERE  job_name = 'PURGE_ALL_AUDIT_TRAILS'
/


rem 
rem Create a job that advance the archive timestamp
rem

DECLARE
    already_exists exception;
    pragma exception_init( already_exists, -27477);
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'set_last_archive_timestamp_job',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'DECLARE
                        BEGIN 
                         sys.set_last_archive_timestamp;  
                        END;',
    start_date      => trunc(SYSTIMESTAMP)+2/24,
    repeat_interval => 'freq=daily; byhour=0; byminute=0; bysecond=0;',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Automatically set audit last archive time.');
exception
when already_exists then
    dbms_output.put_line('Archive timestamp advance job is already exists.');
END;
/


set line 250
col owner format a10
col job_name format a30
col start_date format a40
col repeat_interval format a30
col LAST_START_DATE format a40
col NEXT_RUN_DATE format a40

select owner, job_name, state, enabled, start_date, REPEAT_INTERVAL, LAST_START_DATE, LAST_RUN_DURATION, NEXT_RUN_DATE
 from dba_scheduler_jobs 
 where owner = 'SYS'
   and job_name in ( 'PURGE_ALL_AUDIT_TRAILS', 'SET_LAST_ARCHIVE_TIMESTAMP_JOB');


rem
rem check the clean up job log
rem
col AUDIT_TRAIL for a25
col CLEANUP_TIME for a45
select audit_trail,rac_instance,cleanup_time,delete_count from dba_audit_mgmt_clean_events order by cleanup_time;
 
select * from DBA_AUDIT_MGMT_CLEANUP_JOBS;

spool off

exit





