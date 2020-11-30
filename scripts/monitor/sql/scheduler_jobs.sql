set line 250
col owner format a25
col job_name format a30
col LAST_START_DATE format a40
col LAST_RUN_DURATION format a40
col STATE format a15
col NEXT_RUN_DATE format a40

SELECT owner, job_name, enabled, LAST_START_DATE, LAST_RUN_DURATION, STATE, NEXT_RUN_DATE , STORE_OUTPUT
from dba_scheduler_jobs
/

