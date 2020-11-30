set line 250
col backup_task format a60
col duration format a40
col backup_type format a30
set pagesize 80

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

prompt "Backup Type"

select listagg(input_type, ' | ') within group (order by input_type) "BACKUP_TYPE"
 from ( select distinct input_type
         from v$rman_backup_job_details)
/


accept input_type prompt "Backup Type:"


select lpad(' ', 3*level - 1 ) || RECID||' '||OPERATION||' '||OBJECT_TYPE BACKUP_TASK,STATUS, START_TIME,END_TIME,
       floor(((END_TIME-START_TIME)*24*60*60)/3600)|| ' Hour(s) ' ||
          floor((((END_TIME-START_TIME)*24*60*60) - floor(((END_TIME-START_TIME)*24*60*60)/3600)*3600)/60) || ' Minute(s) ' ||
          round((((END_TIME-START_TIME)*24*60*60) - floor(((END_TIME-START_TIME)*24*60*60)/3600)*3600 -
                 (floor((((END_TIME-START_TIME)*24*60*60) - floor(((END_TIME-START_TIME)*24*60*60)/3600)*3600)/60)*60) ))|| ' Second(s) ' DURATION
  from v$rman_status
connect by prior RECID = PARENT_RECID
 start with PARENT_RECID is null
   and recid in (select max(session_key)
                   from v$rman_backup_job_details
                  where input_type = upper('&input_type'))
 order by start_time
/

