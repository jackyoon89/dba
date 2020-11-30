REM ===========================================================================================
REM
REM  Script:  large_objs.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>LARGE OBJECT</H3>
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Segment Name</B> - Name of the segment
prompt <LI><B>Segment Type</B> - Type of segment
prompt <LI><B>Tablespace Name</B> - Name of the tablespace
prompt <LI><B>Bytes</B> - Size of the object 
prompt <LI><B>Initial Extent</B> - Size of the initial extent (bytes) 
prompt <LI><B>Next Extent</B> - Size of the next extent (bytes) 
prompt <LI><B>Extents</B> - Current number of extents
prompt <LI><B>Percent Increase</B> - Percent increase for object
prompt <P>
prompt <LI> This reports shows objects larger than the average segment size of all database segments.
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Owner</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Segment<BR>Name</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Segment<BR>Type</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Tablespace<BR>Name</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Bytes (1)</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Initial Extent</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Next Extent</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Extents</B></FONT></TD>
prompt 	<TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Percent<BR>Increase</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||segment_name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||segment_type||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||tablespace_name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(bytes,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(initial_extent,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||decode(next_extent,NULL,'&nbsp;',to_char(next_extent,'999,999,999,999,999'))||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(extents,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(pct_increase,NULL,'&nbsp;',decode(pct_increase,0,'0','<FONT COLOR="#FF0000" FACE="Arial" SIZE="2">'||pct_increase||'</FONT>'))||'</FONT></TD>
	</TR>'
from 	dba_segments
where   bytes > (select avg(bytes) 
        from dba_segments
        where owner in ('TEMAIN',PIVOTAL','EJVUSER','DBMON'))
and     owner in ('TEMAIN',PIVOTAL','EJVUSER','DBMON')
order 	by bytes desc; 
prompt </TABLE><BR>
prompt <br><br>
