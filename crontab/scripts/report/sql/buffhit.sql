REM ===========================================================================================
REM
REM  Script:  buffhit.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>BUFFER HIT RATIO</H3> 
prompt <LI><B>Consistent Gets</B> - The number of accesses made to the block buffer to retrieve data in a 
prompt consistent mode.
prompt <LI><B>DB Blk Gets</B> - The number of blocks accessed via single block gets (i.e. not through
prompt the consistent get mechanism).
prompt <LI><B>Physical Reads</B> - The cumulative number of blocks read from disk.
prompt <P>
prompt <LI>Logical reads are the sum of <B>consistent gets</B> and <B>db block gets</B>.
prompt <LI>The <B>db block gets</B> statistic value is incremented when a block is read for update and when segment header
prompt blocks are accessed.
prompt <LI>The buffer hit ratio (also known as read hit ratio) is one indicator that identifies whether to add more database block buffers.  This buffer hit ratio identifies the difference between the number of reads from disk versus memory (found in the database block buffers).If your system is highly interactive, then a good rule of thumb is to ensure the buffer hit ratio is greater than 95 percent. If your system is highly batch reporting, then a good rule of thumb is to ensure the buffer hit ratio is greater than 85 percent.  Keep in mind it is much faster to find data in memory than going to disk, therefore, if there is memory to increase the database block buffers without hurting system resources, then more memory should be added to this area to increase these percentages. 
prompt <LI>Hit Ratio should be > 85%, else increase DB_BLOCK_BUFFERS in init.ora 
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Consistent Gets</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>DB Blk Gets</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Physical Reads</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Hit Ratio</B></FONT></TD>
prompt </TR>
select '<TR>
	 <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(decode(name, 'consistent gets',value, 0)),'999,999,999,999,999')||'</FONT></TD>
         <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(decode(name, 'db block gets',value, 0)),'999,999,999,999,999')||'</FONT></TD>
         <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(sum(decode(name, 'physical reads',value, 0)),'999,999,999,999,999')||'</FONT></TD>
         <TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||round((sum(decode(name, 'consistent gets',value, 0)) +
         sum(decode(name, 'db block gets',value, 0)) - sum(decode(name, 'physical reads',value, 0))) /
         (sum(decode(name, 'consistent gets',value, 0))  + sum(decode(name, 'db block gets',value, 0)) )  * 100,3)||'</FONT></TD>
	</TR>'
from sys.v_$sysstat;
prompt </TABLE><BR>
prompt <br><br>
