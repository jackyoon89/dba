REM ===========================================================================================
REM
REM  Script:  tiloc.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>TABLE/INDEX LOCATION</H3>
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Tablespace Name</B> - Location of the object
prompt <LI><B>Tables Type</B> - Count for tables
prompt <LI><B>Indexes</B> - Count for indexes
prompt <P>
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Tablespace Name (2)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Tables</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Indexes</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||tablespace_name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||sum(decode(segment_type,'TABLE',1,0))||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||sum(decode(segment_type,'INDEX',1,0))||'</FONT></TD>
	</TR>'
from 	dba_segments
where	segment_type in ('TABLE','INDEX')
  and   owner not in ( 'DIP','TSMSYS','DBSNMP','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OUTLN','MGMT_VIEW','SYS','SYSTEM')
group 	by owner, tablespace_name;
prompt </TABLE><BR>
prompt <br><br>
