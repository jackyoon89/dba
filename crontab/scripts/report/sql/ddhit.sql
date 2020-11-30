REM ===========================================================================================
REM
REM  Script:  ddhit.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>DATA DICTIONARY HIT RATIO</H3> 
prompt <LI><B>Gets</B> -  Total number of requests for information on the data object.
prompt <LI><B>Cache Misses</B> - Number of data requests resulting in cache misses 
prompt <P>
prompt <LI>Hit Ratio should be &gt; 90%, else increase SHARED_POOL_SIZE in init.ora
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Gets</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Cache Misses</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Hit Ratio</B></FONT></TD>
prompt </TR>
select '<TR>
	 <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(gets),'999,999,999,999,999')||'</FONT></TD>
	 <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(getmisses),'999,999,999,999,999')||'</FONT></TD>
   <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round((1 - (sum(getmisses) / sum(gets))) * 100,3)||'</FONT></TD>
	</TR>' 
from 	sys.v_$rowcache;
prompt </TABLE><BR>
prompt <br><br>
