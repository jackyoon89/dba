REM ===========================================================================================
REM
REM  Script:  libhit.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>LIBRARY CACHE HIT RATIO</H3> 
prompt <LI><B>Executions</B> - Number of times the system issues pin request for objects in the cache in order to access them
prompt <LI><B>Execution Hits</B> - Number of times the system is pinning and accessing are already allocated and initialized in the cache.  Otherwise, it is a miss, and the system has to allocate it in the cache and initilize it with data queried from the database or generate the data.
prompt <LI><B>Misses</B> - Number of times that library objects have to reinitialized and reloaded with data because they have been aged out or invalidated
prompt <P>
prompt <LI>There is an execution (pin) hit ratio and a reload hit ratio.  The recommended hit ratio for both is greater than 99 percent.  If either of the hit ratios falls below this percentage, it indicates that the shared pool can be increased to improve overall performance.  
prompt <LI>Hit Ratio should be &gt; 95%, else increase SHARED_POOL_SIZE in init.ora  
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Executions</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Execution<BR>Hits</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Hit<BR>Ratio</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Misses</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Hit<BR>Ratio</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(pins),'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(pinhits),'999,999,999,999,999')||'</FONT></TD>
   	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round((sum(pinhits) / sum(pins)) * 100,3)||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(reloads),'999,999,999,999,999')||'</FONT></TD>
   	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round((sum(pins) / (sum(pins) + sum(reloads))) * 100,3)||'</FONT></TD>
	</TR>' 
from 	sys.v_$librarycache;
prompt </TABLE><BR>
prompt <br><br>
