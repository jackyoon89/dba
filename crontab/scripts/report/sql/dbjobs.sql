prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>DATABASE JOBS</H3>
prompt <LI><B>Log User</B> - USER who was logged in when the job was submitted.
prompt <LI><B>Schema</B> - Default schema used to parse the job.
prompt <LI><B>Job#</B> - Identifier of job. 
prompt <LI><B>Interval</B> - A date function, evaluated at the start of execution, becomes next NEXT_DATE.
prompt <LI><B>Next Execution</B> - Date/time that this job will next be executed.
prompt <LI><B>Broken</B> - If Y, no attempt is made to run this job. See DBMS_JOBQ.BROKEN (JOB). 
prompt <LI><B>What</B> - Body of the anonymous PL/SQL block that this job executes.
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Log User (1)</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Schema</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Job#</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Interval</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Next Execution</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Broken</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>What</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||log_user||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||schema_user||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||job||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||interval||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||to_char(next_date,'MM/DD/YYYY HH24:MI:SS')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||broken||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||substr(what,1,100)||'</FONT></TD>
	</TR>'
from 	dba_jobs
order 	by log_user;
prompt </TABLE><BR>
