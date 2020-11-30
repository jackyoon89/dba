set line 180
col username format a30
col profile format a30

select username, profile, account_status from dba_users
where username in ('C##ADMIN','CRONTAB')
/


select username, sysdba, sysoper, sysasm, sysbackup account_status from v$pwfile_users
/

show parameter db_name
show parameter service
