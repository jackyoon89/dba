set line 180
col owner format a30
col table_name format a30
col index_Name format a30

SELECT OWNER,TABLE_NAME,INDEX_NAME, status FROM DBA_INDEXES WHERE OWNER = 'WHITNEY' and status <> 'VALID';

