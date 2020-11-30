set heading off
set feedback off
set line 80
set pagesize 80

select 'assigned:'||round(sum(bytes)/1024/1024/1024)
 from dba_data_files
union
select 'free:'||round(sum(bytes)/1024/1024/1024)
 from dba_free_space
/

exit
