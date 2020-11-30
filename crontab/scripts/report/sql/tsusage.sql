REM ===========================================================================================
REM
REM  Script:  tsusage.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>TABLESPACE USAGE INFORMATION</H3>
prompt <LI><B>Tablespace Name</B> - Name of the tablespace
prompt <LI><B>Bytes Allocated</B> - Total space allocated in bytes
prompt <LI><B>Bytes Used</B> - Used space in bytes
prompt <LI><B>Percent Used</B> - Percentage of tablespace that is being used
prompt <LI><B>Bytes Free</B> - Free space in bytes
prompt <LI><B>Percent Free</B> - Percentage of tablespace that is free
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Tablespace<BR>Name</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Bytes<BR>Allocated</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Bytes Used</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Percent<BR>Used (1)</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Bytes Free</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Percent<BR>Free</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||ddf.tablespace_name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(ddf.bytes,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char((ddf.bytes-dfs.bytes),'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(round(((ddf.bytes-dfs.bytes)/ddf.bytes)*100,2),'990.90')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(dfs.bytes,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(round((1-((ddf.bytes-dfs.bytes)/ddf.bytes))*100,2),'990.90')||'</FONT></TD>
	</TR>'
from 	(select	tablespace_name,
	sum(bytes) bytes
	from dba_data_files
	group by tablespace_name) ddf,
	(select tablespace_name,
	sum(bytes) bytes
	from dba_free_space
	group by tablespace_name) dfs
where 	ddf.tablespace_name=dfs.tablespace_name
order 	by ((ddf.bytes-dfs.bytes)/ddf.bytes) desc;

select '<TR>
	<TD><FONT FACE="Arial" SIZE="2"><B>'||'TOTALS'||'</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum(ddf.bytes),'999,999,999,999')||'</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum(ddf.bytes-dfs.bytes),'999,999,999,999')||'</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||'&nbsp;'||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum(dfs.bytes),'999,999,999,999')||'</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||'&nbsp;'||'</FONT></TD>
	</TR>'
from 	(select	tablespace_name,
	sum(bytes) bytes
	from dba_data_files
	group by tablespace_name) ddf,
	(select tablespace_name,
	sum(bytes) bytes
	from dba_free_space
	group by tablespace_name) dfs
where	ddf.tablespace_name = dfs.tablespace_name;
prompt </TABLE><BR>

prompt <br><br>
