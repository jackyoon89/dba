REM ===========================================================================================
REM
REM  Script:  sysstatt.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SYSTEM EVENTS </H3>
prompt <P>
prompt <LI>The V$SYSTEM_EVENT displays aggregated statistics of all wait events encountered by all Oracle sessions since the instance
prompt startup. It keeps track of the total number of waits, total timeouts, and timed waited for any wait event ever encountered by any of the sessions.
prompt (Unit of measure for wait event timing is centiseconds(1/100th))
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99"NOWRAP><FONT FACE="Arial" SIZE="2"><B>WAIT_CLASS</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>EVENT</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>TOTAL_WAITS</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>TOTAL_TIMEOUTS</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>TIME_WAITED</B></FONT></TD>
prompt  <TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>AVERAGE_WAIT</B></FONT></TD>
prompt </TR>
select '<TR>
	 <TD><FONT FACE="Arial" SIZE="2">'||WAIT_CLASS||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||EVENT||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(TOTAL_WAITS,'999,999,999,999,999,999,999')||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(TOTAL_TIMEOUTS,'999,999,999,999,999,999,999')||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(TIME_WAITED,'999,999,999,999,999,999,999')||'</FONT></TD>
	 <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(AVERAGE_WAIT,'999,999,999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	V$SYSTEM_EVENT
order by WAIT_CLASS,TIME_WAITED;
prompt </TABLE><BR>
prompt <br><br>
