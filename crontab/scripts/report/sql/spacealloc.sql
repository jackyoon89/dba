REM ===========================================================================================
REM
REM  Script:  spacealloc.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>USER SPACE ALLOCATED</H3>
prompt <LI><B>Owner</B> - Owner of the object(s)
prompt <LI><B>Type</B> - Type of object
prompt <LI><B>Size</B> - Size in bytes (for all objects)

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Type (2)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Size(MB)</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||segment_type||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(sum(bytes),'999,999,999,999,999,999,999')||'</FONT></TD>
	</TR>'
from   sys.dba_segments
group  by  owner, segment_type
order by owner;
prompt </TABLE><BR>
prompt <br><br>
