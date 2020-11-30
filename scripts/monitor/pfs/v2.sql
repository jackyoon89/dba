set line 180

rem alter session set current_schema=DVSWEB;

explain plan for
   SELECT FUNDCODE,
          ACCTNOSYSTEM,
          (SELECT MAX (UDKTOG)
             FROM FV_KTOG_OF_KTO kg
            WHERE kg.IDKTO = xx.IDKTO AND kg.UDKGS = 'ACCOUNTNUMBER')
             AS ACCTNO,
          ACCTDESC,
          d.uddev AS CCY,
          NAME,
          BALANCE
     FROM (SELECT f.udfo AS FundCode,
                  k.idkto AS IDKTO,
                  k.udkto AS AcctNoSystem,
                  k.szkto AS AcctDesc,
                  k.idktodev AS IDKTODEV,
                  k.szkto AS name,
                  k.fcsaldo AS balance
             FROM fis.fv_kto k,
                  fis.fv_fonds f,
                  (SELECT DISTINCT idfund
                     FROM DVSWEB.vw_ais_fund_hierarchy_matrix) fm
            WHERE k.idfo = fm.idfund AND f.idfo = k.idfo
           UNION ALL
           SELECT f.udfo AS FundCode,
                  kp.IDKTO AS IDKTO,
                  kp.udkto AS AcctNoSystem,
                  kp.szkto AS AcctDesc,
                  kp.idktodev AS IDKTODEV,
                  kp.szkto AS name,
                  0 AS balance
             FROM    DVSWEB.VWM_AIS_GLMAP_SUPPORT_MATRIX GLS
                  INNER JOIN
                     FIS.FT_FONDS F
                  ON f.idfo = GLS.IDFUND,
                  (SELECT DISTINCT idfund
                     FROM DVSWEB.vw_ais_fund_hierarchy_matrix) fm,
                  fvb_kto_plan kp
            WHERE     gls.idfund = fm.idfund
                  AND gls.idaccount = kp.idkto
                  AND gls.idaccount NOT IN (SELECT idkto FROM fis.ft_kto)) xx,
          fis.FVB_DEVISE d
    WHERE d.iddev = xx.idktodev;

