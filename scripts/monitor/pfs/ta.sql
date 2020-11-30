rem sql_id : 375xu2qsthzw4
rem 
explain plan for
SELECT AVG(dt) AS avgtime 
  FROM (SELECT a.idrun, MAX(a.dt) - MIN(a.dt) AS dt 
          FROM adm_mapper a, 
               (SELECT idrun, COUNT(*) AS nztasks 
                  FROM adm_mapper 
                 GROUP BY idrun
               ) n1, 
               (SELECT MAX(nztasks) AS nztasks 
                  FROM (SELECT idrun, COUNT(*) AS nztasks 
                          FROM adm_mapper 
                         GROUP BY idrun)
               ) n2,
               (SELECT MAX(maxtime) AS maxtime 
                 FROM (SELECT idrun, MAX(dt) - MIN(dt) AS maxtime 
                         FROM adm_mapper 
                        GROUP BY idrun)
               ) t1 
         WHERE n2.nztasks - n1.nztasks < :"SYS_B_0"  
           AND a.idrun = n1.idrun 
         GROUP BY a.idrun, t1.maxtime)
/

explain plan for
with a as ( SELECT idrun, COUNT(*) nztasks, MAX(dt) maxdt, MIN(dt) mindt
              FROM adm_mapper 
             GROUP BY idrun),
b as (select idrun, max(nztasks) max_nztasks
        from a 
       group by idrun)
select avg(dt) as avgtime
  from ( select a.idrun, a.maxdt - a.mindt as dt
           from a, b
          where a.idrun = b.idrun
            and b.max_nztasks - nztasks < :1 )
/

