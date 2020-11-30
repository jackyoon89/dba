prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>USER SESSIONS</H3>
prompt <LI><B>Username</B> - Oracle username
prompt <LI><B>OS User</B> - Operating system client username 
prompt <LI><B>Count</B> - Number of sessions for this user 
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Username (2)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>OS User (3)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Count (1)</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||username||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||nvl(osuser,'&nbsp;')||'</FONT></TD>
	<TD NOWRAP ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||count(*)||'</FONT></TD>
	</TR>'
from 	sys.v_$session
where 	username is not NULL
group 	by username, osuser
order	by count(*) desc, username, osuser;
prompt </TABLE><BR>
