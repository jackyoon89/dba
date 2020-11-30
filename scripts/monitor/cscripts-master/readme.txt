Carlos Sierra's Shared Scripts 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
last update: 2015/12/28

Feel free to use these scripts. They are mostly useful in the scope of SQL performance
diagnostics. Keep original names please.

Script Name                 YY/MM/DD Purpose
~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
act.sql                     14/10/13 Active Sessions (lite)
active_sessions.sql         14/10/31 Active Sessions (more columns)
active_sql.sql              14/10/31 Simple list of Active SQL (just sql id and text)
alter_plans.sql             13/12/28 Alter attributes of a SQL Plan Baseline
columns_multiple_types.sql  15/07/07 List Columns with multiple data types
constraints_nonindexed.sql  15/07/05 List FK Constrains with no index to supportthem
data_files_usage.sql        14/02/12 Reports Datafiles and Tablespaces usage
dba_hist_ash_summaries.sql  13/12/19 ASH summaries by timed events then by plan operation
estimate_index_size.sql     14/07/18 Reports Indexes with an Actual size > Estimated size for over 1 MB
evolve.sql                  13/12/18 Evolve SQL Plan Baselines
find_apex.sql               14/09/03 Finds APEX related expensive SQL for given application user and session
gather_stats_wr_sys.sql     15/10/15 Gather fresh CBO statistics for AWR Tables and Indexes
largest_200_objects.sql     14/01/23 Reports 200 largest objects as per segments bytes
list_plans.sql              13/12/28 Lists SQL Plan Baselines
mystat_reset.sql            13/10/04 Resets snaps credated by mystat.sql
mystat.sql                  14/01/11 Reports delta of current sessions stats before and after a SQL
one_sql_time_series.sql     14/10/31 Performance History for one SQL
plan_prev.sql               13/10/09 Execution Plan for last SQL executed in current session
profiler.sql                12/07/02 Generates HTML report out of DBMS_PROFILER data
recent.sql                  15/07/09 List of SQL on execution or recently executed
planx.sql                   15/10/29 Reports Execution Plans for one SQL_ID from RAC and AWR(opt)
sql_perf_change_by_date.sql 14/11/28 Lists SQL Statements with Elapsed Time per Execution changing over time (passing date)
sql_performance_changed.sql 14/11/28 Lists SQL Statements with Elapsed Time per Execution changing over time
sql_with_multiple_plans.sql 14/11/28 Lists SQL Statements with multiple Execution Plans performing significantly different
sqlash.sql                  13/12/18 ASH Reports for one SQL_ID
sqlmon.sql                  13/12/18 SQL Monitor Reports for one SQL_ID
sqlpch.sql                  15/01/28 Create Diagnostics SQL Patch for one SQL_ID
tablex.sql                  14/01/24 Reports CBO Statistics for a given Table
tkprof.sql                  13/10/15 Turns trace off and generates a TKPROF for trace under current session
trace_off.sql               13/10/15 Turns sql trace off
trace_on.sql                13/10/04 Turns sql trace on using event 10046 level 12 (include binds and waits)
verify_stats_wr_sys.sql     15/04/23 Verify CBO statistics for AWR Tables and Indexes
