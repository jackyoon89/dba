set line 180
set pagesize 0
set feedback off

alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';


col message format a150
col datetie format a22

select * from utl$list_tree_nodes;

rem select log#,message from utl$log;


exit
