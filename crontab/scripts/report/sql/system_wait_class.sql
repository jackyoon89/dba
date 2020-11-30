REM ===========================================================================================
REM
REM  Script:  system_wait_class.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SYSTEM WAIT CLASS</H3>
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99"NOWRAP><FONT FACE="Arial" SIZE="2"><B>WAIT_CLASS</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>TOTAL_WAITS</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>TIME_WAITED</B></FONT></TD>
prompt </TR>
select '<TR>
	 <TD><FONT FACE="Arial" SIZE="2">'||WAIT_CLASS||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(TOTAL_WAITS,'999,999,999,999,999,999,999')||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(TIME_WAITED,'999,999,999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	V$SYSTEM_WAIT_CLASS
order by TIME_WAITED;
prompt </TABLE><BR>
prompt <br><br>
