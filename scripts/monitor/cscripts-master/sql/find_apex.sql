----------------------------------------------------------------------------------------
--
-- File name:   find_apex.sql
--
-- Purpose:     Finds APEX poorly performing SQL for a given application user and session
--
-- Author:      Carlos Sierra
--
-- Version:     2014/09/03
--
-- Usage:       Inputs APEX application user and session id, and outputs list of poorly 
--              performing SQL statements for further investigation with other tools.
--
-- Example:     @find_apex.sql
--
-- Notes:       Developed and tested on 11.2.0.3.
--
--              Requires an Oracle Diagnostics Pack License since ASH data is accessed.
--
--              To further investigate poorly performing SQL use sqld360.sql 
--              (or planx.sql or sqlmon.sql or sqlash.sql).
--             
---------------------------------------------------------------------------------------
--
WHENEVER SQLERROR EXIT SQL.SQLCODE;
ACC confirm_license PROMPT 'Confirm with "Y" that your site has an Oracle Diagnostics Pack License: '
BEGIN
  IF NOT '&&confirm_license.' = 'Y' THEN
    RAISE_APPLICATION_ERROR(-20000, 'You must have an Oracle Diagnostics Pack License in order to use this script.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;
--
COL seconds FOR 999,990;
COL appl_user FOR A30;
COL min_sample_time FOR A25;
COL max_sample_time FOR A25;
COL apex_session_id FOR A25;
COL page FOR A4;
COL sql_text FOR A80;
--
SELECT COUNT(*) seconds,
       SUBSTR(client_id, 1, INSTR(client_id, ':') - 1) appl_user,
       MIN(sample_time) min_sample_time,
       MAX(sample_time) max_sample_time
  FROM gv$active_session_history
 WHERE module LIKE '%/APEX:APP %'
 GROUP BY 
       SUBSTR(client_id, 1, INSTR(client_id, ':') - 1)
HAVING SUBSTR(client_id, 1, INSTR(client_id, ':') - 1) IS NOT NULL
 ORDER BY
       1 DESC, 2
/
--
ACC appl_user PROMPT 'Enter application user: ';
--
SELECT MIN(sample_time) min_sample_time,
       MAX(sample_time) max_sample_time,
       SUBSTR(client_id, INSTR(client_id, ':') + 1) apex_session_id,
       COUNT(*) seconds
  FROM gv$active_session_history
 WHERE module LIKE '%/APEX:APP %'
   AND SUBSTR(client_id, 1, INSTR(client_id, ':') - 1) = TRIM('&&appl_user.')
 GROUP BY 
       SUBSTR(client_id, INSTR(client_id, ':') + 1)
 ORDER BY
       1 DESC
/
--
ACC apex_session_id PROMPT 'Enter APEX session ID: ';
--
SELECT COUNT(*) seconds,
       SUBSTR(h.module, INSTR(h.module, ':', 1, 2) + 1) page,
       h.sql_id,
       SUBSTR(s.sql_text, 1, 80) sql_text
  FROM gv$active_session_history h,
       gv$sql s
 WHERE h.module LIKE '%/APEX:APP %'
   AND SUBSTR(h.client_id, 1, INSTR(h.client_id, ':') - 1) = TRIM('&&appl_user.')
   AND SUBSTR(h.client_id, INSTR(h.client_id, ':') + 1) = TRIM('&&apex_session_id.')
   AND s.sql_id = h.sql_id
   AND s.inst_id = h.inst_id
   AND s.child_number = h.sql_child_number
 GROUP BY 
       SUBSTR(h.module, INSTR(h.module, ':', 1, 2) + 1),
       h.sql_id,
       SUBSTR(s.sql_text, 1, 80)
 ORDER BY
       1 DESC, 2, 3
/
--
PRO Use sqld360.sql (or planx.sql or sqlmon.sql or sqlash.sql) on SQL_ID of interest