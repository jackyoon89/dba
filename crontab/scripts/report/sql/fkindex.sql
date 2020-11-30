REM ===========================================================================================
REM
REM  Script:  fkindex.sql
REM  Author:  Jack Yoon ( jack.yoon@gmail.com )
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>FK CONSTRAINTS WITHOUT INDEX ON CHILD TABLE</H3>
prompt <LI><B>Owner</B> - Owner of the table
prompt <LI><B>Constraint Name</B> - Name of the constraint
prompt <LI><B>Column Name</B> - Name of the column
prompt <LI><B>Position</B> - Position of the index
prompt <LI><B>Problem</B> - Nature of the problem
prompt <P>
prompt <LI>It is highly recommended that an index be created if the Foreign Key 
prompt column is used in joining, or often used in a WHERE clause.  Otherwise a 
prompt table level lock will be placed on the parent table.
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Owner (1)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Constraint Name (2)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Column Name (3)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER" NOWRAP><FONT FACE="Arial" SIZE="2"><B>Position (4)</B></FONT></TD>
prompt 	<TD BGCOLOR="#CCCC99" ALIGN="CENTER"><FONT FACE="Arial" SIZE="2"><B>Problem</B></FONT></TD>
prompt </TR>
select '<TR>
	<TD><FONT FACE="Arial" SIZE="2">'||acc.owner||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||acc.constraint_name||'</FONT></TD>
	<TD><FONT FACE="Arial" SIZE="2">'||acc.column_name||'</FONT></TD>
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||acc.position||'</FONT></TD> 
	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||'No Index'||'</FONT></TD>
	</TR>'
from   	dba_cons_columns acc, dba_constraints ac
where  	ac.constraint_name = acc.constraint_name
and   	ac.constraint_type = 'R'
and     acc.owner not in ( 'DIP','TSMSYS','DBSNMP','SYSMAN','ANONYMOUS','MDSYS','ORDSYS','EXFSYS','WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OUTLN','MGMT_VIEW','SYS','SYSTEM')
and     not exists (
        select  'TRUE' 
        from    dba_ind_columns b
        where   b.table_owner = acc.owner
        and     b.table_name = acc.table_name
        and     b.column_name = acc.column_name
        and     b.column_position = acc.position)
order   by acc.owner, acc.constraint_name, acc.column_name, acc.position;
prompt </TABLE><BR>
prompt <br><br>

