set heading off
set feedback off
set line 80
set pagesize 80
set verify off

select 'total_gb:'||(case when free_mb > usable_file_mb then (total_mb/2)/1024 else total_mb/1024 end )||
       ' used_gb:'||(case when free_mb > usable_file_mb then (total_mb/2 - usable_file_mb)/1024 else (total_mb - usable_file_mb)/1024 end ) 
  from crontab.asm_space_usage
 where name = upper('&1')
/

exit
