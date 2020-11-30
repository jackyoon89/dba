REM ===========================================================================================
REM
REM  Script:  shpool2.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <B>SHARED POOL MEMORY USAGE NOTES:</B><BR>
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Object</B> - Name/namespace of the object
prompt <LI><B>Sharable Memory</B> - Amount of sharable memory in the shared pool consumed by the object
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Owner</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Object</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Sharable Memory (1)</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'|| name||' - '||type||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(sharable_mem,'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	sys.v_$db_object_cache
where 	sharable_mem > 10000
and 	type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
order 	by sharable_mem desc;
prompt </TABLE><BR>
prompt <br><br>
