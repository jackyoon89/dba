REM ===========================================================================================
REM
REM  Script:  sysstatt.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SYSTEM STATISTICS (TABLE) </H3>
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99"NOWRAP><FONT FACE="Arial" SIZE="2"><B>CLASS</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99"NOWRAP><FONT FACE="Arial" SIZE="2"><B>STAT NAME</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>VALUE</B></FONT></TD>
prompt </TR>
select '<TR>
	 <TD><FONT FACE="Arial" SIZE="2">'||w.wait_class||'</FONT></TD>
	 <TD><FONT FACE="Arial" SIZE="2">'||s.name||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(s.value,'999,999,999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	v$sysstat s, v$system_wait_class w
where s.class = w.wait_class#;
prompt </TABLE><BR>
prompt <br><br>
