
whenever sqlerror exit failure;

prompt -------> Existing SQL Tuning Sets 
prompt

set line 180
col name format a25
col description format a30

select id, name, owner, last_modified, statement_count from dba_sqlset;


prompt ------> Please provide SQL Tuning Set Name 
prompt

accept sqlset_name  prompt 'SqlSet Name:';

variable v_task varchar2(64);

exec :v_task := dbms_sqlpa.create_analysis_task(sqlset_name => upper('&sqlset_name'));

print :v_task


prompt ------> Executing Analysis before change
prompt

begin
    dbms_sqlpa.execute_analysis_task( 
                 task_name      => :v_task,
                 execution_type =>  'test execute',
                 execution_name => upper('before_change'));
end;
/
