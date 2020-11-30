Alter system flush buffer_cache;
Alter system flush shared_pool;

insert into global_ports_blotter select portfolio from mhfshdr;

set autotrace on;
set line 180
set pagesize 800
set timing on;

SELECT COUNT(*) FROM (
SELECT  min(RcPy.Ref) AS FirstRef FROM pamrcpy RcPy WHERE RcPy.BlockID > 0 AND RcPy.PostType <> 7 AND 
RcPy.ExpdCashDate BETWEEN TO_DATE('2014/9/8','YYYY/MM/DD') AND TO_DATE('2014/10/7','YYYY/MM/DD')  
and (RcPy.Bank IN   ('AMG','BBH','BK1','BN2','BN3','BNP','BNY','BOA','BVA','CH2','CH3','CH4','CHS','CIT','CSB','DBF','DEU','DUM','ERS','FB2','FID','FLT','FUB','HSC',
'IFT','KAS','LAN','LOY','MIP','MIT','MLN','MSU','NAB','NOR','NTR','PMF','PNC','PS2','RBC','SEB','SGR','SS2','SSB','SUN','UBC','UBZ','UMB','US2', 'USB','WE2','WEB','WEL','PSI'))
and rcpy.portfolio in (select portfolio from global_ports_blotter)
GROUP BY RcPy.BlockID, RcPy.Bank
);

