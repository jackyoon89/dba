set line 180
set pagesize 800

alter session set current_schema=FIS;

explain plan for
SELECT r.IDFOTS, m.IDFOTG, Fmt.IDFTEXTCODE, min(FMT.idns), min(FMT.iddsn)
  FROM CUST_FT_MAPFOTG m, 
       CUST_FT_FOTGRUPPE a, 
       CUST_FT_FOTGOFFTC fmt,
       (SELECT IDFOTS, IDPARFOTS
          FROM CUST_FT_FOTGROUPSCHEMA s
         WHERE IDFOTS NOT IN (SELECT IDFOTS FROM CUST_FT_FOTGOFFTC)
           AND IDFOTS <> IDPARFOTS
         START WITH IDFOTS = IDPARFOTS
       CONNECT BY PRIOR IDFOTS = IDPARFOTS AND ISMASTER = 'N') r
 WHERE Fmt.IDFOTG = m.IDFOTG
   AND a.IDFOTS = r.IDFOTS
   AND m.IDFOTG = a.IDFOTG
   AND NOT EXISTS ( SELECT 1
                      FROM CUST_FT_FOTGOFFTC
                     WHERE IDFOTS = r.IDFOTS
                       AND IDFOTG = a.IDFOTG
                       AND IDFTEXTCODE = fmt.IDFTEXTCODE)
   AND EXISTS ( SELECT 1
                  FROM CUST_FT_FOTGOFFTC
                 WHERE ROWNUM = 1)
GROUP BY r.IDFOTS, m.IDFOTG, Fmt.IDFTEXTCODE
/
 
