rem
rem This script create audit_history table to store audit_trail records
rem for long period. Maintaining audit records in the aud$ table has a limited size
rem and potentially makes your database freeze in case if it reaches max size. So, it is 
rem always recommended to archive(or truncate) your aud$ regular basis.
rem
rem History 
rem jyoon	2010/01/25	Created
rem

drop table system.audit_history
/


create table system.audit_history
tablespace users
as select OS_USERNAME,USERHOST,USERNAME,TIMESTAMP,ACTION_NAME,OBJ_NAME,RETURNCODE,COMMENT_TEXT
  from DBA_AUDIT_TRAIL
 order by TIMESTAMP DESC
/  



create or replace procedure sys.truncate_audit_table
as
begin
    execute immediate 'truncate table sys.aud$';
end;
/

grant execute on sys.truncate_audit_table to c##admin
/

grant execute on sys.truncate_audit_table to crontab
/

