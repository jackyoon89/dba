set heading off
set verify off

alter session set container=&1;

select * from dual;

exit
