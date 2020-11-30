set line 180
set event foramt a40
col P1TEXT format a20
col P2TEXT format a20
col P3TEXT format a20
col wait_class format a15

select event, P1TEXT,P1,P2TEXT,P2,P3TEXT,P3, wait_class from v$session_wait
where WAIT_CLASS not in ('Idle')
order by wait_time
/
