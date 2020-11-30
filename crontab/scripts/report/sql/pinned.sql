REM ===========================================================================================
REM
REM  Script:  pinned.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <B>PINNED OBJECT NOTES:</B><BR>
prompt <LI><B>Object Owner</B> - Owner of the object
prompt <LI><B>Object Name</B> - Name of the object
prompt <LI><B>Object Type</B> - Type of the object (INDEX, TABLE, CLUSTER, VIEW, SET, SYNONYM, 
prompt SEQUENCE, PROCEDURE, FUNCTION, PACKAGE, PACKAGE BODY, TRIGGER, CLASS, OBJECT, USER, DBLINK)
prompt <LI><B>Kept Status</B> - YES or NO, depending on whether this object has been "kept" (permanently pinned in memory) with the PL/SQL procedure DBMS_SHARED_POOL.KEEP 


prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Owner (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Name (2)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Object Type (3)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>Kept Status</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||type||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||kept||'</FONT></TD>
	</TR>'
from 	sys.v_$db_object_cache
where 	kept = 'YES'
order	by owner, name, type;
prompt </TABLE><BR>

prompt <br><br>


