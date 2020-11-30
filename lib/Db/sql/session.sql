set line 130
col username format a10
col machine  format a15
col osuser   format a10
col program  format a30
set pagesize 24
break on machine

select machine,status,count(*)
  from v$session
group by machine,status
/

