set pagesize 80

select sql_id, operation_type, last_execution from v$sql_workarea
where last_execution <> 'OPTIMAL'
order by sql_id
/
