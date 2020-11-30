rem
rem File Name : index_usage_report.sql
rem 

set pagesize 0
set line 180
set verify off
set heading off
set feedback off


select '<TR>
        <TD BGCOLOR="#99FF99" NOWRAP><FONT FACE="Arial" SIZE="2">'||SEQUENCE_NAME||'</FONT></TD>
        <TD BGCOLOR="#99FF99" NOWRAP ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(LAST_NUMBER,'999,999,999,999')||'</FONT></TD>
        </TR>'
FROM ALL_SEQUENCES
WHERE SEQUENCE_OWNER='WHITNEY'
ORDER BY LAST_NUMBER DESC;

exit
