set line 180

select s.sid, s.serial#, t.xidusn, t.used_ublk, t.used_urec
  from v$session s, v$transaction t
 where t.addr = s.taddr
   and s.sid = &1;

