alter session set current_schema=MAN;

explain plan for
select avg(maxdt - mindt) as avgtime
  from (select idrun, count(*) nztasks, max(dt) maxdt, min(dt) mindt, max() over ( partition by count(*)) max_nztasks
         from adp_mapper
        group by idrun)
 where max_nztasks - nztasks < :1
/

explain plan for
select avg(maxdt - mindt) as avgtime
  from (select idrun, count(*) nztasks, max(dt) maxdt, min(dt) mindt, count(*) keep ( dense_rank first order by 1 desc) max_nztasks
          from adm_mapper
         group by idrun)
 where max_nztasks - nztasks < :1
/
