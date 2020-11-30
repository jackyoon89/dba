col name format a25
set line 130

select * from (
select name,addr, latch#,child#,misses,sleeps
from v$latch_children
where misses > 10000
order by misses desc
) where rownum < 20
/

