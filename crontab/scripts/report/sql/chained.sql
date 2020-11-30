REM ===========================================================================================
REM
REM  Script:  chained.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>TABLES EXPERIENCING CHAINING</H3>
prompt <LI><B>Owner Name</B> - Owner of the table
prompt <LI><B>Table Name</B> - Name of the table
prompt <LI><B>Chained Rows</B> - Number of chained rows
prompt <LI><B>Total Rows</B> - Number of total rows 
prompt <LI><B>Percent Chained</B> - Percentage of chained rows
prompt <P>
prompt <LI> Chaining can occur when there is not enough room in the data blocks to
prompt store changes.  A chained record is one that exists in multiple blocks instead
prompt of a single block.  Accessing multiple blocks for the same record can be costly in terms of
prompt performance.
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Table Name</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Chained Rows</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Total Rows</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Percent Chained (1)</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||table_name||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(nvl(chain_cnt,0),'999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(nvl(num_rows,0),'999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char((chain_cnt/num_rows)*100,'999.90')||'</FONT></TD>
	</TR>'
from 	dba_tables
where 	owner not in ( 'DIP','TSMSYS','DBSNMP','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OUTLN','MGMT_VIEW','SYS','SYSTEM')
and 	nvl(chain_cnt,0) > 0
order 	by (chain_cnt/num_rows) desc;
prompt </TABLE><BR>
prompt <br><br>
