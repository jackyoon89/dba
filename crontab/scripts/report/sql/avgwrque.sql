REM ===========================================================================================
REM
REM  Script:  avgwrque.sql
REM  Author:  Stewart McGlaughlin (dba@pobox.com)
REM
REM  OraSnap (Oracle Performance Snapshot)
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>AVERAGE WRITE REQUEST QUEUE LENGTH </H3>
prompt <LI><B>Summed Dirty Queue Length</B> - Value for summed dirty queue length (total)
prompt <LI><B>Write Requests</B> - Value for write requests (total)
prompt <LI><B>Write Request Queue Length</B> - Average request queue length
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Summed Dirty Queue Length</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Write Requests</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Write Request Queue Length</B></FONT></TD>
prompt </TR>
select  '<TR>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'|| nvl(to_char(sum(decode(name,'summed dirty queue length',value)),'999,999,999,999,999'),'0')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'|| nvl(to_char(sum(decode(name,'write requests',value)),'999,999,999,999,999'),'0')||'</FONT></TD>
	<TD ALIGN="CENTER" NOWRAP><FONT FACE="Arial" SIZE="2">'|| nvl(to_char(sum(decode(name,'summed dirty queue length',value)) /
		sum(decode(name,'write requests',value)),'999,999,999,999.90'),'0')||'</FONT></TD>
	</TR>'
from 	sys.v_$sysstat
where  	name in ('summed dirty queue length','write requests')
and  	value > 0;
prompt </TABLE><BR>
prompt <br><br>
