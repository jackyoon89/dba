prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>DATABASE SNAPS</H3>
prompt <LI><B>Owner</B> - Owner of the snapshot 
prompt <LI><B>Name</B> - The view used by users and applications for viewing the snapshot 
prompt <LI><B>Table Name</B> - Table the snapshot is stored in, has an extra column for the master rowid 
prompt <LI><B>Master View</B> - View of the master table, owned by the snapshot owner, used for refreshes 
prompt <LI><B>Master Owner</B> - Owner of the master table 
prompt <LI><B>Master</B> - Name of the master table of which this snapshot is a copy 
prompt <LI><B>Master Link</B> - Database link name to the master site 
prompt <LI><B>Can Use Log</B> - If NO, this snapshot is complex and will never use a log 
prompt <LI><B>Updatable</B> - If NO, the snapshot is read only 
prompt <LI><B>Last Refresh</B> - SYSDATE from the master site at the time of the last refresh 
prompt <LI><B>Error</B> - The number of failed automatic refreshes since last successful refresh 
prompt <LI><B>Type</B> - The type of refresh (complete, fast, force) for all automatic refreshes 
prompt <LI><B>Next Refresh</B> - The date function used to compute next refresh dates 
prompt <LI><B>Refresh Group</B> - GROUP All snapshots in a given refresh group get refreshed in the same transaction 
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Name (2)</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Table<BR>Name</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Master<BR>View</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Master<BR>Owner</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Master</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Master Link</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Can Use<BR>Log?</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Updatable</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Last Refresh</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Error</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Type</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Next Refresh</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Refresh<BR>Group</B></FONT></TD>
prompt </TR>
select 	'<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||table_name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||nvl(to_char(master_view),'&nbsp;')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||master_owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||master||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||nvl(master_link,'&nbsp;')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||can_use_log||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||updatable||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||nvl(to_char(last_refresh),'&nbsp;')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||error||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||type||'</FONT></TD>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||nvl(next,'&nbsp;')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||nvl(to_char(refresh_group),'&nbsp;')||'</FONT></TD>
	</TR>'
from  	dba_snapshots
order 	by owner,name;
prompt </TABLE><BR>
