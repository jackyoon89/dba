select ts#, obj#, dataobj#, sum(value) itl_waits
  from v$segstat
 where statistic_name = 'ITL waits'
 group by ts#, obj#, dataobj#
 having sum(value) > 0
 order by sum(value) desc;

