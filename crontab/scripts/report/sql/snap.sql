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
start sql/db_info       -- Database Information
start sql/sga           -- SGA Information

-- HIT AND MISS RATIOS
start sql/buffhit       -- Buffer Hit Ratio
start sql/libhit        -- SQL Cache Hit Ratio
start sql/ddhit         -- Data Dictionary Hit Ratio
start sql/usersess      -- User Session Information

-- TABLESPACE INFORMATION
rem start sql/datafiles     -- Datafile Information
start sql/tsusage       -- Tablespace Usage
rem start sql/tscoal.sql    -- Tablespace Coalesed Extents
rem start sql/addextent     -- Freespace And Largest Extent

-- USER INFORMATION
start sql/spacealloc    -- User Space Allocated
rem start sql/invalid       -- Invalid Objects
start sql/usermod       -- User Modified Objects (Last 7 Days)

-- TABLES AND INDEXES
start sql/tiloc         -- Table/Index Locations
start sql/chained       -- Tables Experiencing Chaining
rem start sql/fkindex       -- Foreign Key Problems 
start sql/noextend      -- Object Extent Warning        ***LONG RUNNING REPORT***

start sql/dblinks       -- Database Links
start sql/dbjobs        -- Database jobs
rem start sql/dbsnap        -- Database Snapshot
rem start sql/dbsyns        -- Database synonyms

-- DISK I/O, EVENTS AND WAITS
start sql/sorts         -- Sort Statistics
start sql/datafileio    -- Datafile I/O

-- ANALYZE STATISTICS 
rem start sql/analyze.sql   -- Analyze Statistics

-- FULL TABLE SCANS
start sql/systimemodel  -- System Time model
start sql/osstat        -- Operating system Statistics

start sql/system_wait_class  -- System wait calss
start sql/sysstatt      -- System Statistics (Table)
#start sql/sysevent      -- System Event 

-- CURSOR AND SQL PROCESSING
start sql/listsql1      -- Disk Intensive SQL
start sql/listsql2      -- Buffer Intensive SQL

-- SHARED POOL INFORMATION 
start sql/shpool2       -- Shared Pool Memory Usage
start sql/shpool3       -- Shared Pool Loads
start sql/shpool4       -- Shared Pool Executions
start sql/pinned        -- Pinned Objects


-- REDO LOGS
start sql/redoswitch    -- Redo Log Switches

-- MISCELLANEOUS REPORTS
start sql/cpinterval    -- Check Point Interval Summary
start sql/avgwrque      -- Write Request Queue Size

exit

