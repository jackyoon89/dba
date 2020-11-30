REM ===========================================================================================
REM
REM  Script:  datafiles.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>DATAFILE INFORMATION</H3>
prompt <LI><B>File Name</B> - Name of the datafile
prompt <LI><B>Tablespace</B> - Name of the tablespace
prompt <LI><B>Datafile Size</B> - Size of datafile (bytes)
prompt <LI><B>Bytes Used</B> - Amount of datafile used
prompt <LI><B>Percent Used</B> - Percent of datafile used
prompt <LI><B>Bytes Free</B> - Amount of datafile free
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>File Name (2)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Tablespace (1)</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Datafile Size</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Bytes Used</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Percent Used</B></FONT></TD>
prompt  <TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Bytes Free</B></FONT></TD>
prompt </TR>
select  '<TR>
	<TD NOWRAP><FONT FACE="Arial" SIZE="2">'||FILE_NAME||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||d.TABLESPACE_NAME||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(d.BYTES,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(sum(nvl(e.BYTES,0)),'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||round(sum(nvl(e.BYTES,0)) / (d.BYTES), 4) * 100||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char((d.BYTES - sum(nvl(e.BYTES,0))),'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from    dba_extents e,
        dba_data_files d
where   d.FILE_ID = e.FILE_ID (+)
group by FILE_NAME,d.TABLESPACE_NAME, d.FILE_ID, d.BYTES, STATUS
order by d.TABLESPACE_NAME,d.FILE_ID;
select 	'<TR>
	<TD><FONT FACE="Arial" SIZE="2"><B>TOTALS</B></FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2"><B>N/A</B></FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum(d.bytes),'999,999,999,999,999')||'</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum(nvl(sum(e.BYTES),0)),'999,999,999,999,999')||'</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>N/A</B></FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>'||to_char(sum((d.BYTES - sum(nvl(e.BYTES,0)))),'999,999,999,999,999')||'</B></FONT></TD>
	</TR>'
from	dba_extents e,
	dba_data_files d
where	d.file_id = e.file_id (+)
group by d.file_id, d.bytes
order by round(sum(nvl(e.BYTES,0))/(d.BYTES), 4)*100;
prompt </TABLE><BR>
prompt <br><br>


