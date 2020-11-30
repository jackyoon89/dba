set line 130
col opname format a30
col target format a25
 
SELECT SID,OPNAME,TARGET,SOFAR,TOTALWORK,totalwork - sofar difference FROM V$SESSION_LONGOPS
where totalwork - sofar > 0
/

exit
