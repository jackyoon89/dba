REM ===========================================================================================
REM
REM  Script:  usermod.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>OBJECT MODIFIED SINCE LAST 7 DAYS</H3>
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Object Name</B> - Name of the object
prompt <LI><B>Object Type</B> - Type of the object
prompt <LI><B>Last Modified</B> - Last modification date/time
prompt <LI><B>Created</B> - Object creation date/time
prompt <LI><B>Status</B> - Status of the object
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Owner</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Name</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Type</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Last Modified (1)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Created </B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Status</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||object_name||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||object_type||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||to_char(last_ddl_time,'MM/DD/YYYY HH24:MI:SS')||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||to_char(created,'MM/DD/YYYY HH24:MI:SS')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||status||'</FONT></TD>
	</TR>'
from   	dba_objects
where  	(SYSDATE - LAST_DDL_TIME) < 7
and owner not in ( 'SYS','PUBLIC')
order  by  last_ddl_time desc;
prompt </TABLE><BR>

prompt <br><br>
