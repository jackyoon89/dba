drop synonym whitney.gx_support
/

CREATE OR REPLACE package SYS.gx_support
as

    procedure kill_sessions ( p_username in varchar2 );

    procedure cleanup_temp_tables;

    procedure archive_audit_trails ( p_retention in number default 7 );

end gx_support;
/

CREATE OR REPLACE package body SYS.gx_support
as

    /* CHG-14148 : Let techops to kill jasper sessions through whitney */
    procedure kill_sessions ( p_username in varchar2 )
    is
        v_session_cnt number := 0;
    begin
        for i in (select sid, serial#
                    from v$session
                   where username = p_username
                     and sid not in (select sid from v$mystat))
        loop
            execute immediate 'alter system kill session '''||i.sid||','||i.serial#||'''';
            v_session_cnt := v_session_cnt + 1;
        end loop;

        dbms_output.put_line('Total '||v_session_cnt||' session(s) killed.');

    end;


    /* CHG-14038 : Clean up temp table created by MicroStrategy */
    procedure cleanup_temp_tables
    is
    begin
        for i in (select owner, table_name
                    from all_tables
                   where owner in ('ICOPY','RCOPY','TCOPY')
                     and table_name like 'ZZT%')
        loop
            execute immediate 'drop table '||i.owner||'.'||i.table_name||' purge';
        end loop;
    end;


    procedure set_last_archive_timestamp ( p_retention in number )
    is
      v_num_instances number;

      type AuditTrailType is table of number index by binary_integer;
      v_AuditTrailTypes AuditTrailType;
    begin
        v_AuditTrailTypes(0) := 1;    -- AUDIT_TRAIL_AUD_STD
        v_AuditTrailTypes(1) := 4;    -- AUDIT_TRAIL_OS
        v_AuditTrailTypes(2) := 8;    -- AUDIT_TRAIL_XML

        select count(*) into v_num_instances
          from v$thread;

        if v_num_instances > 1 then
            for i in (select value from gv$parameter where name = 'instance_number')
            loop
                for j in v_AuditTrailTypes.first..v_AuditTrailTypes.last
                loop
                    begin 
                        dbms_audit_mgmt.set_last_archive_timestamp (
                               audit_trail_type    => v_AuditTrailTypes(j),
                               rac_instance_number => i.value,
                               last_archive_time   => systimestamp - p_retention );
                    exception when others then
                        null;
		    end; 
                end loop;
            end loop;
        else
            for i in v_AuditTrailTypes.first .. v_AuditTrailTypes.last
            loop

                begin
                    dbms_audit_mgmt.set_last_archive_timestamp (
                           audit_trail_type   => v_AuditTrailTypes(i),
                           last_archive_time  => systimestamp - p_retention );

                exception when others then
                    null;
                end;
            end loop;
        end if;
    end;

    procedure archive_audit_trails ( p_retention in number default 7 )
    is
    begin
        --
        -- move aud$ to sysaux tablespace
        --
        if not dbms_audit_mgmt.is_cleanup_initialized( DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD )
        then
            dbms_audit_mgmt.init_cleanup(
                     audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
                     default_cleanup_interval => 24 /* hours */);

            set_last_archive_timestamp ( p_retention );

            return;
        end if;

        -- Remove old audit_history
        delete from system.audit_history where timestamp < sysdate - ( p_retention * 10 );

        -- Load new audit entries into audit_history table
        insert into system.audit_history
        select os_username,userhost,username,timestamp,action_name,obj_name,returncode,comment_text
          from dba_audit_trail;

        commit;

        dbms_audit_mgmt.clean_audit_trail( dbms_audit_mgmt.AUDIT_TRAIL_ALL, TRUE );

        set_last_archive_timestamp ( p_retention );

    end;

end gx_support;
/

