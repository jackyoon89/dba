set verify off

DELETE FROM WHITNEY.STP_EVENT WHERE LAST_UPDATED_DATE_TIME < SYSDATE - 21;

commit