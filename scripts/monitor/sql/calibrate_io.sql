SET SERVEROUTPUT ON
DECLARE
  l_latency  PLS_INTEGER;
  l_iops     PLS_INTEGER;
  l_mbps     PLS_INTEGER;
BEGIN
   DBMS_RESOURCE_MANAGER.calibrate_io (num_physical_disks => 1, 
                                       max_latency        => 20,
                                       max_iops           => l_iops,
                                       max_mbps           => l_mbps,
                                       actual_latency     => l_latency);
 
  DBMS_OUTPUT.put_line('Max IOPS = ' || l_iops);
  DBMS_OUTPUT.put_line('Max MBPS = ' || l_mbps);
  DBMS_OUTPUT.put_line('Latency  = ' || l_latency);
END;
/



SET LINESIZE 100
COLUMN start_time FORMAT A20
COLUMN end_time FORMAT A20

SELECT TO_CHAR(start_time, 'DD-MON-YYY HH24:MI:SS') AS start_time,
       TO_CHAR(end_time, 'DD-MON-YYY HH24:MI:SS') AS end_time,
       max_iops,
       max_mbps,
       max_pmbps,
       latency,
       num_physical_disks AS disks
FROM   dba_rsrc_io_calibrate;


