REM ===========================================================================================
REM
REM  Script:  listsql2.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt  <H3>SQL WITH MOST BUFFER SCAN</H3> 
prompt  <LI><B>Username</B> - Name of the user
prompt  <LI><B>Buffer Gets</B> - Total number of buffer gets for this statement
prompt  <LI><B>Executions</B> - Total number of times this statment has been executed
prompt  <LI><B>Gets/Execs</B> - Number of buffer gets per execution
prompt  <LI><B>SQL Text</B> - Text of the SQL statement requiring the cursor, or the PL/SQL anonymous code
prompt  <P>
prompt  <LI>The buffer_gets column provides information on SQL statements that may not possess the large disk hits, but possess a large number of memory hits (higher than normally desired).  In this case, the SQL statement may be using an index, but using the wrong index.  These types of SQL statements can involve a join operation that is forcing the path to utilize a different index than desired or using multiple indexes and forcing index merging.  
prompt  <LI>Excessive BUFFER_GETS suggests that the query is causing heavy memory (logical) reads
prompt  <LI>Check for overindexes tables
prompt  </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Username</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Buffer Gets</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Executions</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Gets/Execs (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>SQL Text</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||b.username||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(a.buffer_gets,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(a.executions,'999,999,999,999,999')||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||to_char(a.buffer_gets / decode(a.executions, 0, 1, a.executions),'999,999,999,999,999')||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||replace(replace(sql_text,'<','&lt;'),'>','&gt;') ||'</FONT></TD>
	</TR>' 
from 	sys.v_$sqlarea a, dba_users b
where 	a.parsing_user_id=b.user_id 
and 	a.buffer_gets/decode(a.executions,0,1,a.executions) > 20000
and     a.executions <> 0
and     b.username not in ( 'DIP','TSMSYS','DBSNMP','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OUTLN','MGMT_VIEW','SYS','SYSTEM')
and     sql_text not like '%FONT FACE="Arial"%'
order  	by (a.buffer_gets / decode(a.executions, 0, 1, a.executions)) desc;
prompt </TABLE><BR>
prompt <BR><BR>
