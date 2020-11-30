REM ===========================================================================================
REM
REM  Script:  sysstatt.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>Operating System Statistics </H3>
prompt <LI><B>Operating system statistics</B> provide information about system resource utilization such as CPU, memory, and file systems.
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99"NOWRAP><FONT FACE="Arial" SIZE="2"><B>Statistic Name</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Value</B></FONT></TD>
prompt </TR>
select '<TR>
	 <TD><FONT FACE="Arial" SIZE="2">'||stat_name||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(value,'999,999,999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	v$osstat;
prompt </TABLE><BR>
prompt <br><br>
