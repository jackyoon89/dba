select 'ALTER USER '|| username||' PROFILE APPLICATION_PROFILE;'
from dba_users
where profile='APMD_PROCESS_ID_PROFILE'
/

