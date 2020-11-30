set line 180

select tablespace_name, sum(bytes)/1024/1024  from dba_data_files
group by tablespace_name
/
