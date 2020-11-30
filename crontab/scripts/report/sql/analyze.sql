REM ===========================================================================================
REM
REM  Script:  analyze.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt  <FONT SIZE="2" FACE="Arial">
prompt  <H3>OBJECT LAST ANALYZED</H3></FONT></br>
prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Table Name</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Last Analyzed</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Average Space Occupation</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||table_name||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(last_analyzed,'yyyy/mm/dd hh24:mi:ss')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||avg_space/1024/1024||'</FONT></TD>
	</TR>'
from 	dba_tables
where 	owner not in ( 'SYS','SYSTEM','OUTLN','DBSNMP','PERFSTAT','SYSMAN','EXFSYS','WMSYS','MDSYS','ORDSYS','TSMSYS','XDB' )
order by owner,table_name;
prompt </TABLE><BR>
