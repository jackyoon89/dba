
Filename                   Purpose
-------------------------  ---------------------------------------------------------------------------
auto_pga_parameters.sql    PGA memory allocation

event_name.sql             All events and their class

flashback.sql              Flashback are usage percent 

hidden_parameters.sql      Hidden parameters

index.sql                  Monitor indexes on a table(input: owner table)

latch_children.sql         Top 20 latch children whose misses > 10000
latch_vs_blocks.sql        Database objects blocks protected by child latch(input: hashvalue of child latch)

long_ops.sql               Monitor Long operation

pga_usage.sql              Monitor PGA usage of sessions
pga_usage_total.sql        Monitor sum of PGA usage 

plan.sql                   Show plan table

pq_tqstat.sql              Monitor parallel query table queue statistics
px_session.sql             Monitor parallel wait events for parallel processors

session_wait.sql           Monitor session waits

show_space.sql             Procedure that shows space usage information

sql_workarea_active.sql    Monitor PGA memory management at the session level

tablespace.sql             Shows datafiles and their size(input: tablespace name)


