rem
rem hidden parameters
rem

col name format a40
col value format a20
col description format a80
set line 150

select ksppinm name, ksppstvl value, ksppdesc description
  from x$ksppi x , x$ksppcv y
 where (x.indx = y.indx)
   and x.inst_id = userenv('instance')
   and x.inst_id = y.inst_id
   and ksppinm like '\_%' ESCAPE '\'
 order by name
/
