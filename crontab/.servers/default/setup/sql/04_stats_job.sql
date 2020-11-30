rem Matches : .*
rem Matches : XC.*
rem Matches : ((P|U)0.*|PROD*)

set serverout on

DECLARE
    already_exists exception;
    pragma exception_init( already_exists, -27477);
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
      job_name   => 'GATHER_DATABASE_STATS',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'DECLARE
                     BEGIN
                         DBMS_STATS.GATHER_DATABASE_STATS( ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE, METHOD_OPT => ''FOR ALL COLUMNS SIZE AUTO'', CASCADE => TRUE, DEGREE => 24);
                     END;',
      start_date      => trunc(SYSTIMESTAMP),
      repeat_interval => 'freq=weekly; byday=sat; byhour=16; byminute=0; bysecond=0;',
      end_date        => NULL,
      enabled         => FALSE,
      comments        => 'Database Statistics Gathering.');
exception
when already_exists then
    dbms_output.put_line('GATHER_DATABASE_STATS scheduler job already exists.');
END;
/

exit
