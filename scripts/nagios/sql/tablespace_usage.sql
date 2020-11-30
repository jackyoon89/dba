rem 
rem In this script, we treat freespace as "actual freespace" + "total extensible space - occpuied space".
rem

set line 180
set heading off
set feedback off

rem SELECT DDF.TABLESPACE_NAME, ROUND((DFS.BYTES + (DDF.MAXBYTES - DDF.BYTES))/DDF.MAXBYTES*100,2)

SELECT DDF.TABLESPACE_NAME, 
       CASE 
       WHEN DDF.BYTES > DDF.MAXBYTES THEN
           ROUND((DDF.BYTES - DFS.BYTES)/DDF.BYTES*100,2) 
       ELSE 
           ROUND((DDF.BYTES - DFS.BYTES)/DDF.MAXBYTES*100,2) 
       END
  FROM    (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES, SUM(DECODE(MAXBYTES,0,BYTES,MAXBYTES)) MAXBYTES
             FROM DBA_DATA_FILES 
            GROUP BY TABLESPACE_NAME) DDF,
          (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES 
             FROM DBA_FREE_SPACE 
            GROUP BY TABLESPACE_NAME) DFS 
            WHERE DDF.TABLESPACE_NAME = DFS.TABLESPACE_NAME;

exit

