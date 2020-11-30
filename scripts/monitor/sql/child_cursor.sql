rem
rem Use this script to figure out why child cursors cannot be shared
rem if you see loads >1 from cursor_share.sql
rem

rem
rem v$sqlarea shows parant cursor information
rem 
rem - Display v$sql which has more than 10 children.
rem select * from v$sqlarea where version_count >10
rem order by version_count;

select sql_id, version_count, optimizer_mode, address, hash_value
  from v$sqlarea
 where sql_text like '%select * from emp%'
   and sql_text not like '%v$sql%';


rem
rem v$sql shows child cursor information
rem
select sql_id, child_number, optimizer_mode, address, hash_value, parsing_user_id
  from v$sql
 where sql_text like '%select * from emp%'
   and sql_text not like '%v$sql%';


rem
rem You can query V$SQL_SHARED_CURSOR to see why it has multiple children
rem
rem Common reasons
rem 1. A SQL references different schema(owner) 
rem 2. When a cursor become invalidated but it was not hard parsed since other sessions pin the cursor.
rem 3. Optimizer related parameters are different
rem 4. If the length of the bind variables are different
rem 5. If NLS parameters are different
rem 6. If sqltrace was enabled.

select * from v$sql_shared_cursor;



