whenever sqlerror exit failure;

prompt
prompt ------> Existing SPA Tasks

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

set line 120
col owner format a15
col task_name format a25
col advisor_name format a24

select owner, task_name, advisor_name, last_execution, last_modified
  from dba_advisor_tasks
 where advisor_name = 'SQL Performance Analyzer'
order by owner, task_name;

accept task_name  prompt 'SPA Task Name: ';


prompt
prompt ------> Accepting After Change Excution Name
prompt
accept exec_name2 prompt 'Execution Name: ';

begin
    dbms_sqlpa.execute_analysis_task( 
                 task_name      => '&&task_name',
                 execution_type =>  'test execute',
                 execution_name => '&exec_name2');
end;
/



prompt ------> Accepting Execution name you want to compare

col task_name format a20
 
select execution_name, execution_type, status, execution_end
  from dba_advisor_executions
 where task_name = '&&task_name'
   and execution_name <> '&exec_name2'
   and execution_type <> 'COMPARE PERFORMANCE'
order by execution_type desc, execution_end
/


accept exec_name1 prompt 'Enter Execution Name to compare: '
accept comp_exec_name prompt 'Enter compare Execution Name: '

begin
    dbms_sqlpa.execute_analysis_task(
                 task_name      => '&&task_name',
                 execution_name => upper('&&comp_exec_name'),
                 execution_type => 'compare performance',
                 execution_params => dbms_advisor.arglist(
                                         'execution_name1',
                                         '&exec_name1',
                                         'execution_name2',
                                         '&exec_name2'));
end;
/


select execution_name, execution_type, status, execution_end
  from dba_advisor_executions
 where task_name = '&&task_name'
   and execution_type = 'COMPARE PERFORMANCE'
order by execution_type desc, execution_end
/


variable rep clob;
begin
    :rep := dbms_sqlpa.report_analysis_task(
                upper('&&task_name'), 'HTML', 'ALL', 'ALL', NULL, 100, upper('&&comp_exec_name'));
end;
/

set long 500000000
set longchunksize 500000000
set linesize 200
set head off
set feedback off
set echo off

spool &&task_name._&&comp_exec_name..html
print :rep
spool off
set head off

