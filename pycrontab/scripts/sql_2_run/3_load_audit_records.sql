select count(*) from dba_audit_trail;

insert into system.audit_history
select * from dba_audit_trail;

commit;

truncate table aud$;

exit
