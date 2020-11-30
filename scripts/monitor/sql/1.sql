set pages 999;

column pga_size format 999,999,999

select
    1048576+a.value+b.value   pga_size
from
   v$parameter a,
   v$parameter b
where
   a.name = 'sort_area_size'
and
   b.name = 'hash_area_size'
