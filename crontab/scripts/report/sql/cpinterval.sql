REM ===========================================================================================
REM
REM  Script:  cpinterval.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>CHECKPOINT INTERVAL</H3> 
prompt <LI><B>Shortest</B> - Shortest checkpoint time
prompt <LI><B>Longest</B> - Longest checkpoint time
prompt <LI><B>Average</B> - Average checkpoint time
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Shortest</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Longest</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Average</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round(min(lh2.first_time - lh1.first_time) * 24 * 60,2)||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round(max(lh2.first_time - lh1.first_time) * 24 * 60,2)||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round(avg(lh2.first_time - lh1.first_time) * 24 * 60,2)||'</FONT></TD>
	</TR>'
from 	sys.v_$loghist lh1, sys.v_$loghist lh2
where 	lh1.sequence# + 1 = lh2.sequence#
and 	lh1.sequence# <
	(select max (sequence#)
		from  sys.v_$loghist );
prompt </TABLE><BR>
prompt <br><br>
