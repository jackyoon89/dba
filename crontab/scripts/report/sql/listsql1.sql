
prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SQL WITH MOST DISK READ</H3>
prompt <LI><B>Username</B> - Name of the user
prompt <LI><B>Disk Reads</B> - Total number of disk reads for this statement
prompt <LI><B>Executions</B> - Total number of times this statement has been executed
prompt <LI><B>Reads/Execs</B> - Number of reads per execution
prompt <LI><B>SQL Text</B> - Text of the SQL statement requiring the cursor, or the PL/SQL anonymous code
prompt <P>
prompt <LI>The goal of this statement is to highlight the SQL statements in your system that can potentially be optimized.  The disk_reads signify the volume of disk reads that are being performed on the system.  This combined with the executions (reads/executions) returns the SQL statements that have the most disk hits per statement execution.  Once identified, the top statements should be reviewed and optimized to improve overall performance.  Typically, the statement is not using an index or the execution path is forcing the statement not to use the proper indexes.  This script should be executed regularly to determine if new statements are being introduced to your system that have not been properly optimized.
prompt <LI>Remember 80% of most systems that are improved in terms of performance is directly attributable to poorly written SQL statements.
prompt <LI>
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Username</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Disk Reads</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Executions</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Reads/Execs (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>SQL Text</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||b.username||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(a.disk_reads,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(a.executions,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(a.disk_reads / decode(a.executions, 0, 1, a.executions),'999,999,999,999,999')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||replace(replace(sql_text,'<','&lt;'),'>','&gt;') ||'</FONT></TD>
	</TR>' 
from 	sys.v_$sqlarea a, dba_users b
where 	a.parsing_user_id=b.user_id 
and 	a.disk_reads/decode(a.executions,0,1,a.executions) > 20000
and     b.username not in ( 'DIP','TSMSYS','DBSNMP','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OUTLN','MGMT_VIEW','SYS','SYSTEM')
and 	sql_text not like '%FONT FACE="Arial"%'
and     a.executions <> 0
order  	by (a.disk_reads / decode(a.executions, 0, 1, a.executions)) desc;
prompt </TABLE><BR>
prompt <br><br>
