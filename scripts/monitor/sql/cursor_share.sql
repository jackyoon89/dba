rem
rem If loads > 1 then it means cursor was invalidated
rem we need to check why it cannot share child cursors
rem

set line 180

select sql_id, parse_calls, loads, executions, invalidations,
       decode(sign(invalidations), 1, (loads-invalidations),0) reloads
  from v$sql
 where sql_text like '%scott%'
   and sql_text not like '%v$sql%';



