rem Output will be read by crontab user on FXPROD database
rem using external table
rem
rem create table asm_space_usage
rem ( name varchar2(30),
rem  TOTAL_MB number,
rem  FREE_MB number,
rem  USABLE_FILE_MB number )
rem  organization external
rem  (
rem  type oracle_loader
rem  default directory temp_dir
rem  access parameters (
rem       records delimited by newline
rem       fields terminated by '|'
rem  ) location ( 'asm_space.txt')
rem  );
rem

set line 180
set heading off
set feedback off
set verify off

select name||'|'||total_mb||'|'||free_mb||'|'||usable_file_mb from v$asm_diskgroup;

exit

