SELECT     p.program, p.spid
FROM v$session s, v$process p
WHERE s.paddr = p.addr
AND s.sid = &sid;
