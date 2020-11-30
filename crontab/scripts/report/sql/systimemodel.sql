REM ===========================================================================================
REM
REM  Script:  sysstatt.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>Time Model Statistics </H3>
prompt <LI><B>Time model statistics</B> provide the breakdown of the time a session spent in various steps, such as hard parsing, soft parsing, SQL execution, PL/SQL execution, Java execution, and so on, while performing the actual task. 
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
from 	v$sys_time_model;
prompt </TABLE><BR>
prompt <br><br>
