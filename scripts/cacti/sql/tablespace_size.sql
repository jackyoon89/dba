set heading off
set feedback off
set line 80
set pagesize 80

select tablespace_name||':'||round(sum(bytes)/1024/1024,2)||CHR(10)
from dba_data_files
group by tablespace_name
union
SELECT A.tablespace_name||':'||D.mb_total
  FROM v$sort_segment A,
       (
       SELECT B.name, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM v$tablespace B, v$tempfile C
        WHERE B.ts#= C.ts#
        GROUP BY B.name, C.block_size
       ) D,
      dba_temp_files t
WHERE A.tablespace_name = D.name and a.tablespace_name = t.tablespace_name
/
exit
