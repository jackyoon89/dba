rem
rem this must be run by crontab user
rem 

set serverout on

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
  ( job       => X 
   ,what      => 'update crontab.heartbeat set alive_time = sysdate;'
   ,next_date => to_date('25/10/2015 22:21:48','dd/mm/yyyy hh24:mi:ss')
   ,interval  => 'sysdate+1/(60*24)'
   ,no_parse  => FALSE
  );
  SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;
/

