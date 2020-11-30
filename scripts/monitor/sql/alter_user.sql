set lin 200 longc 1000000 long 1000000 feed off;

accept username  prompt 'Input username: ';

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

select replace(DBMS_METADATA.GET_DDL('USER',upper('&username')),'CREATE USER','ALTER USER') from dual;
