REM ===========================================================================================
REM
REM  Script:  redoswitch.sql
REM  Author:  Jack Yoon (jack.yoon@gmail.com)
REM
REM ===========================================================================================

prompt <FONT SIZE="2" FACE="Arial">
prompt <H3>REDO LOG SWITCH HISTORY </H3>
prompt <LI><B>Day</B> - Date of the switches
prompt <LI><B>00-23</B> - Time of the switch (24 hour)
prompt <P>
prompt <LI>Look for any excessive (&gt;4) log switches during the same hour
prompt <LI>Oracle recommends 15-20 minute log switching
prompt </FONT>

prompt <TABLE BORDER=1 CELLPADDING=5>
prompt <TR>
prompt  <TD ALIGN="LEFT" BGCOLOR="#CCCC99" NOWRAP><FONT FACE="Arial" SIZE="2"><B>DAY (1)</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>00</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>01</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>02</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>03</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>04</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>05</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>06</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>07</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>08</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>09</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>10</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>11</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>12</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>13</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>14</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>15</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>16</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>17</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>18</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>19</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>20</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>21</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>22</B></FONT></TD>
prompt  <TD ALIGN="CENTER" BGCOLOR="#CCCC99"><FONT FACE="Arial" SIZE="2"><B>23</B></FONT></TD>
prompt </TR>
select '<TR>
        <TD ALIGN="LEFT" NOWRAP><FONT FACE="Arial" SIZE="2">'||substr(to_char(first_time,'YYYY/MM/DD, DY'),1,15)||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)))||'</FONT></TD>
       	<TD ALIGN="CENTER"><FONT FACE="Arial" SIZE="2">'||decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)))||'</FONT></TD>
       </TR>'
from 	sys.v_$log_history
group 	by substr(to_char(first_time,'YYYY/MM/DD, DY'),1,15)
order   by substr(to_char(first_time,'YYYY/MM/DD, DY'),1,15) desc;
prompt </TABLE><BR>
prompt <br><br>
