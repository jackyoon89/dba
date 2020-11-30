set line 180

rem alter session set current_schema=DVSWEB;


explain plan for
   SELECT FUNDCODE,
          ACCTNOSYSTEM,
          ACCTNO,
          ACCTDESC,
          CCY,
          NAME,
          BALANCE
     FROM (SELECT (SELECT udfo
                     FROM fvb_fonds
                    WHERE idfo = k.idfo)
                     AS FundCode,
                  k.udkto AS AcctNoSystem,
                  (SELECT MAX (UDKTOG)
                     FROM FV_KTOG_OF_KTO kg
                    WHERE kg.IDKTO = k.IDKTO AND kg.UDKGS = 'ACCOUNTNUMBER')
                     AS AcctNo,
                  k.szkto AS AcctDesc,
                  (SELECT uddev
                     FROM fis.fvb_devise
                    WHERE iddev = k.idktodev)
                     AS ccy,
                  k.szkto AS name,
                  k.fcsaldo AS balance
             FROM fis.fv_kto k,
                  (SELECT DISTINCT idfund FROM dvsweb.vw_ais_fund_hierarchy_matrix) fm
            WHERE k.idfo = fm.idfund
           UNION ALL
           SELECT gl.udfo AS FundCode,
                  kp.udkto AS AcctNoSystem,
                  (SELECT MAX (UDKTOG)
                     FROM FV_KTOG_OF_KTO kg
                    WHERE kg.IDKTO = kp.IDKTO AND kg.UDKGS = 'ACCOUNTNUMBER')
                     AS AcctNo,
                  kp.szkto AS AcctDesc,
                  (SELECT uddev
                     FROM fis.fvb_devise
                    WHERE iddev = kp.idktodev)
                     AS ccy,
                  kp.szkto AS name,
                  0 AS balance
             FROM dvsweb.vwb_ais_fund_glmapping gl,
                  (SELECT DISTINCT idfund FROM dvsweb.vw_ais_fund_hierarchy_matrix) fm,
                  fvb_kto_plan kp
            WHERE     gl.idfund = fm.idfund
                  AND gl.idaccount = kp.idkto
                  AND gl.idaccount NOT IN (SELECT idkto FROM fis.fvb_kto))
/
