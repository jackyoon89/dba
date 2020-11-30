rem
rem Monitor PGA allocation
rem

set line 130
col name format a35
col description format a70

select x.ksppinm name,
       case 
       when x.ksppinm like '%pga%' then to_number(y.ksppstvl)/1024
       else to_number(y.ksppstvl)
       end as "value(KB)",
       x.ksppdesc description
  from x$ksppi x, x$ksppcv y
 where x.inst_id = userenv('Instance')
   and y.inst_id = userenv('Instance')
   and x.indx = y.indx
   and x.ksppinm in ('pga_aggregate_target','_pga_max_size','_smm_max_size','_smm_px_max_size')
/ 
