set heading off
set feedback off
set line 80
set pagesize 80

select lower(file_type)||':'||percent_space_used from v$flash_recovery_area_usage
order by lower(file_type)
/

exit
