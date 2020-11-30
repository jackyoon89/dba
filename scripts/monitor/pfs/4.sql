explain plan for
UPDATE DVSWEB.DV_MAPPING D 
   SET FUNDLIST = ( SELECT DISTINCT F.UDFO 
                      FROM FIS.CUST_FT_LOADDATE_HIST LD INNER JOIN FVB_FONDS F 
                        ON F.IDFO = LD.IDFO 
                     WHERE LD.IDRUN = D.FIS_IDRUN 
                     GROUP BY LD.IDRUN),
       DATELIST = ( SELECT DISTINCT TRUNC(LD.DTMAX) 
                     FROM ( SELECT DISTINCT IDRUN, DTMAX 
                              FROM FIS.CUST_FT_LOADDATE_HIST 
                             ORDER BY DTMAX) LD 
                    WHERE LD.IDRUN = D.FIS_IDRUN 
                    GROUP BY LD.IDRUN) 
WHERE EXISTS ( SELECT LD.IDRUN 
                 FROM FIS.CUST_FT_LOADDATE_HIST LD 
                WHERE LD.IDRUN = D.FIS_IDRUN )
/



