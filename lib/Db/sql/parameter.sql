SET line 180
SET heading off
SET feedback off
SET verify off
col value format a180

SELECT value
  FROM v$parameter
 WHERE name = lower('&1')
/

exit

