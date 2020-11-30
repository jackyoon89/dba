
SET TIMING ON
SET ECHO ON

WHENEVER SQLERROR CONTINUE

SET HEADING OFF

SELECT 'Account termination started at                   : '||SYSTIMESTAMP FROM DUAL;

SET HEADING ON

exec whitney.purge_master.UPDATE_TERMINATED_USER;

exec whitney.purge_master.UPDATE_TERMINATED_PARTY;

SET HEADING OFF

SELECT 'Account termination finished at                   : '||SYSTIMESTAMP FROM DUAL;

SET HEADING ON


exit
