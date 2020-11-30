set line 180
set pagesize 0
set long 30000
set verify off
rem set feedback off

rem col sql format a50
rem col spid format 999999
rem col sid format 999999


rem select s.username||'"'||s.sql_id||'"'|| (select sql_fulltext from v$sqlarea a where a.sql_id = s.sql_id ) sql

select s.username||'"'||s.sql_id
  from v$session s, v$process p
 where s.paddr = p.addr
   and p.spid = &1
   and s.sql_id is not null
/

exit

