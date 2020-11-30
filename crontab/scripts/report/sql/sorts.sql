REM ===========================================================================================
REM
REM  Script:  sorts.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>SORT ACTIVITY</H3>
prompt <LI><B>Sort Parameter</B> - Name of the sort parameter
prompt <LI><B>Value</B> - Number of sorts
prompt <P>
prompt <LI><B>sorts (memory)</B> - The number of sorts small enough to be performed entirely in sort areas
prompt without using temporary segments.
prompt <LI><B>sorts (disk)</B> - The number of sorts that were large enough to require the use of temporary
prompt segments for sorting.
prompt <LI><B>sorts (rows)</B> - Number of sorted rows
prompt <P>
prompt <LI>The memory area available for sorting is set via the SORT_AREA_SIZE and SORT_AREA_RETAINED_SIZE init.ora parameters.
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Sort Parameter</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Value</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||name||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(value,'999,999,999,999,999')||'</FONT></TD>
	</TR>'
from 	sys.v_$sysstat
where 	name like 'sort%';
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2"><B>'||'% of disk sorts'||'</B></FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>'||to_char(100*a.value/decode((a.value+b.value),0,1,(A.value+b.value)),'999.90')||'</B></FONT></TD>
	</TR>'
from 	sys.v_$sysstat a, sys.v_$sysstat b
where 	a.name = 'sorts (disk)'
and 	b.name = 'sorts (memory)';
prompt </TABLE><BR>
prompt <br><br>
