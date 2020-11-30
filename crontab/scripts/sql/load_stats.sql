
merge into crontab.snap_osstat cs
using (select inst_id, stat_name, value from gv$osstat where inst_id = userenv('instance')) os
   on (cs.inst_id = os.inst_id and cs.stat_name = os.stat_name)
 when matched then
      update set cs.value = decode(sign(os.value - nvl(cs.last_value,0)), -1, os.value, os.value - nvl(cs.last_value,0) ),
                 cs.last_value = os.value
 when not matched then
      insert values ( os.inst_id, os.stat_name, os.value, 0 )
/


merge into crontab.snap_sysstat cs
using (select inst_id, name, value from gv$sysstat where inst_id = userenv('instance')) ss
   on ( cs.inst_id = ss.inst_id and cs.name = ss.name )
 when matched then 
      update set cs.value = decode(sign(ss.value - nvl(cs.last_value,0)), -1, ss.value, ss.value - nvl(cs.last_value,0) ),
                 cs.last_value = ss.value
 when not matched then
      insert values ( ss.inst_id, ss.name, ss.value, 0 )
/



merge into crontab.snap_system_event ce
using (select inst_id, event, average_wait, wait_class from gv$system_event where inst_id = userenv('instance') ) se
   on ( ce.inst_id = se.inst_id and ce.event = se.event )
 when matched then
      update set ce.average_wait = decode(sign(se.average_wait - nvl(ce.last_average_wait,0)), -1, se.average_wait, se.average_wait - nvl(ce.last_average_wait,0)),
                 ce.last_average_wait = se.average_wait
 when not matched then
      insert values ( se.inst_id, se.event, se.wait_class, se.average_wait, 0 )
/

commit
/

exit
