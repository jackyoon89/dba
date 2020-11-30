rem - Optimal
rem Optimal size is when the size of a work area is large enough that it can accommodate the input data and 
rem auxiliary memory structures allocated by its associated SQL operator. This is the ideal size for the work area.
rem 
rem - One-pass
rem One-pass size is when the size of the work area is below optimal size and an extra pass is performed over part of 
rem the input data. With one-pass size, the response time is increased.
rem 
rem - Multi-pass
rem Multi-pass size is when the size of the work area is below the one-pass threshold and multiple passes over the input data 
rem are needed. With multi-pass size, the response time is dramatically increased because the size of the work area is too small compared to the input data size.
rem

set pagesize 80

select low_optimal_size/1024 "Low(K)",
       (high_optimal_size + 1)/1024 "High(k)",
       optimal_executions "Optimal",
       onepass_executions "One-pass",
       multipasses_executions "Multi-pass"
from v$sql_workarea_histogram
where total_executions <> 0
/
