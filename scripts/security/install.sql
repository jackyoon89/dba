rem
rem feature
rem
rem 1. Log user's login information into SYSTEM.AUDIT_USER_LOGIN table
rem 2. Keep the information for 60 days.
rem 

@audit_user.sql

@db_trigger.sql

@craudithist.sql

@set_audit.sql
