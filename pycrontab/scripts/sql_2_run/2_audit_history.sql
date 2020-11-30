set echo on

drop table system.audit_history;

create table system.audit_history
tablespace users
partition by range(timestamp)
interval(numtoyminterval(1,'MONTH'))
(
partition values less than(to_date('2019/01/01','yyyy/mm/dd'))
)
as
select * from dba_audit_trail
where 1 = 2;

exit
