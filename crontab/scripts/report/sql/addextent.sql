REM ===========================================================================================
REM
REM  Script:  addextent.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>FREE AND LARGEST EXTENT</H3> 
prompt <LI><B>Tablespace</B> - Name of the tablespace
prompt <LI><B>Total Free Space</B> - Total amount (bytes) of freespace in the tablespace
prompt <LI><B>Largest Free Extent</B> - Largest free extent (bytes) in the tablespace
prompt </FONT>

prompt <TABLE BORDER=1>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Tablespace (1)</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Total Free Space</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Largest Free Extent</B></FONT></TD>
prompt </TR>
select 	'<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||tablespace_name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(sum(bytes),'999,999,999,999,999')||'</FONT></TD>
   	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(max(bytes),'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	dba_free_space
group 	by tablespace_name
order 	by sum(bytes);
prompt </TABLE><BR>
prompt <br><br>
