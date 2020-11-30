set line 180
col profile format a30
col limit format a30

select * from dba_profiles
order by 1,2
/
