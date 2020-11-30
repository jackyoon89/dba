clear screen
set line 130
col file_name format a50
col tablespace_name format a25

accept tblsp prompt "Enter Tablespacename: "

select tablespace_name,file_id,file_name,bytes/1024/1024 "MB" from dba_data_files
where tablespace_name = upper('&&tblsp');

undefine tblsp
