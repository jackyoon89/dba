prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>TABLESPACE COALESCED EXTENTS</H3>
prompt <LI><B>Tablespace Name</B> - Name of the tablespace
prompt <LI><B>Total Extents</B> - Total number of free extents in tablespace 
prompt <LI><B>Extents Coalesced</B> - Total number of coalesced free extents in tablespace 
prompt <LI><B>% Extents Coalesced</B> - Percentage of coalesced free extents in tablespace 
prompt <LI><B>Total Bytes</B> - Total number of free bytes in tablespace 
prompt <LI><B>Bytes Coalesced</B> - Total number of coalesced free bytes in tablespace 
prompt <LI><B>Total Blocks</B> - Total number of free oracle blocks in tablespace 
prompt <LI><B>Blocks Coalesced</B> - Total number of coalesced free Oracle blocks in tablespace 
prompt <LI><B>% Blocks Coalesced </B> - Percentage of coalesced free Oracle blocks in tablespace 
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Tablespace<BR>Name (1)</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Total Extents</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Extents<BR>Coalesced</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>% Extents<BR>Coalesced</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Total Bytes</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Bytes Coalesced</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Total Blocks</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Blocks Coalesced</B></FONT></TD>
prompt 	<TD ALIGN="RIGHT" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>% Blocks<BR>Coalesced</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||tablespace_name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(total_extents,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(extents_coalesced,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(percent_extents_coalesced,'999.90')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(total_bytes,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(bytes_coalesced,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(total_blocks,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(blocks_coalesced,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2">'||to_char(percent_blocks_coalesced,'999.90')||'</FONT></TD>
	</TR>'
from 	dba_free_space_coalesced
order 	by tablespace_name;
prompt </TABLE><BR>
