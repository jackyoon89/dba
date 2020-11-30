rem 
rem Monitor PGA memory management at the session level 
rem


set line 180

select to_number(decode(sid, 65535, null, sid)) sid,
       sql_id,
       operation_type operation,
       trunc(expected_size/1024/1024) esize_mb,
       trunc(actual_mem_used/1024/1024) mem_mb,
       trunc(max_mem_used/1024/1024) maxmem_mb,
       number_passes pass,
       trunc(tempseg_size/1024/1024) tempseg_size_mb
  from v$sql_workarea_active
order by 1,2
/

