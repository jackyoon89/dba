set line 180

accept dest_no prompt 'Dest_id : '

select round((max(primary_time) - max(standby_time)) * 24 * 60 , 2)
            from ( select max(next_time) primary_time, to_date(NULL) standby_time
                     from v$archived_log
                    where archived  = 'YES'
                      and dest_id = 1
union all
select to_date(null), max(next_time)
  from v$archived_log
 where archived = 'YES'
   and applied = 'YES'
   and dest_id = &dest_no) 
/
