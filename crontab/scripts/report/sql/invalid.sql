REM ===========================================================================================
REM
REM  Script:  invalid.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>INVALID OBJECT(S)</H3> 
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Object Type</B> - Type of object
prompt <LI><B>Object Name</B> - Name of the object
prompt <LI><B>Status</B> - Status of the object

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Type (2)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Name (3)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Status</B></FONT></TD>
prompt </TR>
select 	'<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||object_type||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||object_name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||status||'</FONT></TD>
	</TR>'
from 	dba_objects
where 	status = 'INVALID'
order 	by owner, object_type, object_name;
prompt </TABLE><BR>
prompt <br><br>

