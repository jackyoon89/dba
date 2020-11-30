REM ===========================================================================================
REM
REM  Script:  db_info.sql
REM  Author:  Jack Yoon (jack.yoon@gmail.cmo)
REM  
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>DATABASE INFORMATION</H3>
prompt <LI><B>Database Name</B> - Name of the database
prompt <LI><B>Created</B> - Date/time the database was created
prompt <LI><B>Log Mode</B> - Archive log mode: NOARCHIVELOG or ARCHIVELOG
prompt <LI><B>Checkpoint Change#</B> - Last SCN checkpointed
prompt <LI><B>Archive Change#</B> - Last SCN archived
prompt </FONT>

prompt <FONT FACE="Arial" SIZE="2">
prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Database Name</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Created</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Log Mode</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>CheckPoint<BR>Change #</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Archive<BR>Change #</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||name||'</FONT></TD>
	<TD ALIGN="CENTER" NOWRAP><FONT FACE="Arial" SIZE="2">'||created||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||log_mode||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||checkpoint_change#||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||archive_change#||'</FONT></TD>
	</TR>'
from 	sys.v_$database;
prompt </TABLE>
prompt <P>
prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Started</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Uptime</B></FONT></TD>
prompt </TR>
SELECT  '<TR>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(startup_time, 'DD-MON-YYYY HH24:MI:SS')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||trunc( sysdate - ( startup_time) ) || ' day(s), ' ||
        trunc(  24*((sysdate-startup_time) -
                trunc(sysdate-startup_time)))||' hour(s), ' ||
        mod(trunc(1440*((sysdate-startup_time) -
                trunc(sysdate-startup_time))), 60) ||' minute(s), ' ||
        mod(trunc(86400*((sysdate-startup_time) -
                trunc(sysdate-startup_time))), 60) ||' seconds' ||'</FONT></TD>
	</TR>'
FROM    sys.v_$instance;
prompt </TABLE><BR>
prompt <br><br>
