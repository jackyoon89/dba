col STATUS format a20
col hrs format 999.99  
set line 210
col start_time format a25
col end_time format a25
col TIME_TAKEN_DISPLAY format a20
col INPUT_BYTES_DISPLAY format a20
col OUTPUT_BYTES_DISPLAY format a20

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

select sid, recid, output
  from v$rman_output
 where session_recid = (select max(session_recid) from v$rman_status) order by recid
/
