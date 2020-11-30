REM ===========================================================================================
REM
REM  Script:  snap.sql
REM  Author:  Jack Yoon 
REM
REM  Desc:    This script generates HTML formatted reports.
REM        
REM ===========================================================================================

set echo        off
set feedback    off
set verify      off
set heading     off
set pause       off
set define      off
set timing      off

set trimspool   on

set pagesize    0
set linesize    500

ttitle off
btitle off

prompt <FONT SIZE="5" FACE="Arial" COLOR="#FF0000">
select '<B>DATABASE('||name||') MONITORING REPORT('||to_char(sysdate,'yyyy/mm/dd')||')</B></FONT>'
  from v$database;

-- GENERAL INFORMATION 
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/db_info       -- Database Information
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/sga           -- SGA Information

-- HIT AND MISS RATIOS
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/buffhit       -- Buffer Hit Ratio
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/libhit        -- SQL Cache Hit Ratio
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/ddhit         -- Data Dictionary Hit Ratio
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/usersess      -- User Session Information

-- TABLESPACE INFORMATION
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/datafiles     -- Datafile Information
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/tsusage       -- Tablespace Usage
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/tscoal.sql    -- Tablespace Coalesed Extents
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/addextent     -- Freespace And Largest Extent

-- USER INFORMATION
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/spacealloc    -- User Space Allocated
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/invalid       -- Invalid Objects
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/usermod       -- User Modified Objects (Last 7 Days)

-- TABLES AND INDEXES
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/tiloc         -- Table/Index Locations
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/chained       -- Tables Experiencing Chaining
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/fkindex       -- Foreign Key Problems 
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/noextend      -- Object Extent Warning        ***LONG RUNNING REPORT***

start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/dblinks       -- Database Links
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/dbjobs        -- Database jobs
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/dbsnap        -- Database Snapshot
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/dbsyns        -- Database synonyms

-- DISK I/O, EVENTS AND WAITS
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/sorts         -- Sort Statistics
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/datafileio    -- Datafile I/O

-- ANALYZE STATISTICS 
rem start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/analyze.sql   -- Analyze Statistics

-- FULL TABLE SCANS
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/systimemodel  -- System Time model
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/osstat        -- Operating system Statistics

start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/system_wait_class  -- System wait calss
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/sysstatt      -- System Statistics (Table)
#start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/sysevent      -- System Event 

-- CURSOR AND SQL PROCESSING
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/listsql1      -- Disk Intensive SQL
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/listsql2      -- Buffer Intensive SQL

-- SHARED POOL INFORMATION 
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/shpool2       -- Shared Pool Memory Usage
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/shpool3       -- Shared Pool Loads
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/shpool4       -- Shared Pool Executions
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/pinned        -- Pinned Objects


-- REDO LOGS
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/redoswitch    -- Redo Log Switches

-- MISCELLANEOUS REPORTS
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/cpinterval    -- Check Point Interval Summary
start /home/app/oracle/admin/DBA/crontab/scripts/report/sql/avgwrque      -- Write Request Queue Size

exit

