select event,p1text,p1,p2text,p2,p3text,p3 from v$session_wait
where sid = &1
/
