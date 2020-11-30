REM ===========================================================================================
REM
REM  Script:  shpool4.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SHARED POOL EXECUTION </H3>
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Object</B> - Name/namespace of the object
prompt <LI><B>Executions</B> - Total number of times this object has been executed
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Owner</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Object</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Executions (1)</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'|| name||' - '||type||'</FONT></TD>
  <TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(executions,'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	sys.v_$db_object_cache
where 	executions > 100
and 	type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
order 	by executions desc;
prompt </TABLE><BR>
prompt <br><br>
