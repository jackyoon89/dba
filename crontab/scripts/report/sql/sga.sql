REM ===========================================================================================
REM
REM  Script:  sga.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SGA INFORMATION</H3>
prompt <LI><B>Name</B> - SGA component group
prompt <LI><B>Value</B> - Memory size in bytes
prompt <P>
prompt <LI>This reports shows the SGA memory structures of your system.  
prompt <LI><B>Database Buffers</B> - The value of the init.ora parameters DB_BLOCK_BUFFERS multiplied by DB_BLOCK_SIZE
prompt <LI><B>Redo Buffers</B> - The value of the init.ora parameter LOG_BUFFER
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Name</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Value</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(value,'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	sys.v_$sga;
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2"><B>TOTAL SGA</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum(value),'999,999,999,999,999')||'</B></FONT></TD>
	</TR>'
from 	sys.v_$sga;
prompt </TABLE><BR>
prompt <br><br>


