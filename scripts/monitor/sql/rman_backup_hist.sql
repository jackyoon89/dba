col STATUS format a20
col hrs format 999.99  
set line 210
col start_time format a25
col end_time format a25
col TIME_TAKEN_DISPLAY format a20
col INPUT_BYTES_DISPLAY format a20
col OUTPUT_BYTES_DISPLAY format a20

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select SESSION_KEY, START_TIME, END_TIME, INPUT_TYPE, STATUS, TIME_TAKEN_DISPLAY, OPTIMIZED, COMPRESSION_RATIO, OUTPUT_DEVICE_TYPE, INPUT_BYTES_DISPLAY, OUTPUT_BYTES_DISPLAY
 from V$RMAN_BACKUP_JOB_DETAILS 
order by SESSION_KEY
/




 

