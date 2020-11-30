REM ===========================================================================================
REM
REM  Script:  datafileio.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>DATAFILE I/O </H3>
prompt <LI><B>File Name</B> - Datafile name
prompt <LI><B>Physical Reads</B> - Number of physical reads
prompt <LI><B>Reads %</B> - Percentage of physical reads
prompt <LI><B>Physical Writes</B> - Number of physical writes
prompt <LI><B>Writes %</B> - Percentage of physical writes
prompt <LI><B>Total Block I/O's</B> - Number of I/O blocks
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>File Name</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Physical<BR>Reads</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Reads %</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Physical<BR>Writes</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Writes %</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Total Block<BR>I/O (1)</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||name||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(phyrds,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round((phyrds / pd.phys_reads)*100,2)||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(phywrts,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round(phywrts * 100 / pd.phys_wrts,2)||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(to_number(fs.phyblkrd+fs.phyblkwrt),'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	(select sum(phyrds) phys_reads,
	sum(phywrts) phys_wrts
	from sys.v_$filestat) pd,
	sys.v_$datafile df,
	sys.v_$filestat fs
where 	df.file# = fs.file#
order 	by fs.phyblkrd+fs.phyblkwrt desc;
prompt </TABLE><P>
prompt <br><br>


