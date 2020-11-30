REM ===========================================================================================
REM
REM  Script:  noextend.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>OBJECTS THAT CANNOT EXTEND </H3>
prompt <LI><B>Owner</B> - Owner of the object
prompt <LI><B>Object Name</B> - Name of the object
prompt <LI><B>Object Type</B> - Type of object
prompt <LI><B>Tablespace</B> - Name of the tablespace
prompt <LI><B>Next Bytes</B> - Size of next extent
prompt <LI><B>Max Bytes</B> - Max extent size (bytes)
prompt <LI><B>Sum Bytes</B> - Sum of free space (bytes)
prompt <LI><B>Current Extents</B> - Number of current extents for object
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Name (2)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Object Type</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Tablespace</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Next Bytes</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Max Bytes</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="RIGHT"><FONT FACE="Arial" SIZE="2"><B>Sum Bytes</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Current<BR>Extents</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Avail<BR>Extents</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="1">'||ds.owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="1">'||ds.segment_name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="1">'||ds.segment_type||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="1">'||ds.tablespace_name||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="1">'||to_char(ds.next_extent,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="1">'||to_char(dfs.max,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="RIGHT"><FONT FACE="Arial" SIZE="1">'||to_char(dfs.sum,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="1">'||ds.extents||'</FONT></TD>
<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="1">'||decode(floor(dfs.max/ds.next_extent),0,'<FONT COLOR="#FF0000">0</FONT>',floor(dfs.max/ds.next_extent))||'</FONT></TD>
 	</TR>'
from    dba_segments ds,
       (select max(bytes) max,
	sum(bytes) sum,
	tablespace_name
	from dba_free_space
	group by tablespace_name) dfs
where 	ds.next_extent > dfs.max
and     ds.tablespace_name = dfs.tablespace_name
and     ds.owner not in ( 'DIP','TSMSYS','DBSNMP','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OUTLN','MGMT_VIEW','SYS','SYSTEM')
order 	by ds.owner, ds.tablespace_name, ds.segment_name;
prompt </TABLE><BR>
prompt <br><br>
