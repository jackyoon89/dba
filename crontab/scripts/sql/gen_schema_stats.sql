SET PAGESIZE 0
SET LINESIZE 180

REM
REM Generate Script
REM ----------------

SPOOL &1/sql/gather_schema_stats.sql

SELECT 'SET ECHO ON'||CHR(10)||'SET TIMING ON' FROM DUAL
/

SELECT 'PROMPT Schema '||USERNAME||' analyzed : '||CHR(10)||
       'EXEC DBMS_STATS.GATHER_SCHEMA_STATS( '''||USERNAME||''' );'
  FROM DBA_USERS
 WHERE USERNAME NOT IN ('SYSTEM','SYS','OUTLN','DBSNMP','PERFSTAT','RESTORE','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMATION_SCHEMA','DIP','TSMSYS','SCOTT','CTXSYS','WKSYS','WKPROXY','HR','SH','SI_INFORMTN_SCHEMA')
/

SELECT 'EXIT' FROM DUAL
/

SPOOL OFF

REM
REM Execute Script
REM --------------

alter session set optimizer_mode=all_rows;


SPOOL &1/log/gather_schema_stats.log

@&1/sql/gather_schema_stats.sql

SPOOL OFF
