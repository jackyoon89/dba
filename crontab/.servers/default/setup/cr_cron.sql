create user crontab identified by PejWZnQgD0xhnT3tU3gZBQ 
default tablespace users;

grant dba to crontab;

grant sysdba to crontab;

create profile application_profile 
limit PASSWORD_LIFE_TIME UNLIMITED;

alter user crontab profile application_profile;
