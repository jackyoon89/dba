select child_number, open_versions, fetches, rows_processed , executions, px_servers_executions, parse_calls, buffer_gets
  from v$sql
 where sql_id = '&1'
 order by child_number
/
