drop user admin cascade
/

create user c##admin identified by PejWZnQgD0xhnT3tU3gZBQ
default tablespace users
/

grant dba to admin
/

alter session set current_schema=admin
/

drop sequence admin.seq_task_monitor
/

create sequence admin.seq_task_monitor
/

drop table admin.task_monitor
/

rem STATUS IN ( RUNNING, FAILED, SUCCEEDED )
create table admin.task_monitor
(
    task_no      number not null primary key,
    task_name    varchar2(30) not null,
    db_name      varchar2(30) not null,
    start_time   date not null,
    end_time     date,
    est_end_time date,
    status       varchar2(10) not null,
    task_output  clob
) tablespace users
/

