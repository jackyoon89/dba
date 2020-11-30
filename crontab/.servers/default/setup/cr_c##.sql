create user c##admin identified by PejWZnQgD0xhnT3tU3gZBQ container=all
default tablespace users;

grant dba to c##admin container=all;

grant sysdba to c##admin container=all;

create profile c##application_profile 
limit PASSWORD_LIFE_TIME UNLIMITED
container=all;

alter user c##admin profile c##application_profile container=all;
