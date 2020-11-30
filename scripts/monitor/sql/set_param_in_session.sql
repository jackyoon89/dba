rem
rem Set parameter in other's session
rem
rem exec dbms_system.set_int_param_in_session( &sid, &serial_no, '&parameter', &value);
rem

exec dbms_system.set_int_param_in_session( &&sid, &&serial, 'optimizer_index_caching', 100);
exec dbms_system.set_int_param_in_session( &&sid, &serial, 'optimizer_index_cost_adj', 1);


select name, value 
  from  V$SES_OPTIMIZER_ENV 
 where sid=&sid
   and name like 'optimizer_index_%';
