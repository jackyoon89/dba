set pagesize 120

select 'alter user '||username||' profile user_profile;'
from dba_users
where regexp_like(username, '.*[0-9]+.*')
and username not like 'APEX%'
and username not like 'FIRCSE%'
and username not like 'PII%'
order by 1
/
