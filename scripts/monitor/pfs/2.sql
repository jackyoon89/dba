explain plan for 
      SELECT DISTINCT
             idfund,
             idaccount,
             idktog,
             FIRST_VALUE (udlevelgroup)
                OVER (PARTITION BY idfund, idaccount, idktog ORDER BY priority ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                AS LEVELGROUP
        FROM (SELECT b.idfund,
                     b.idaccount,
                     ktog.idktog,
                     glm.udlevelgroup,
                     fh.priority
                FROM -- all fund/account pairs from balances and transactions
                    (SELECT DISTINCT idfo idfund, idkto idaccount FROM fis.fv_kto_stand
                     UNION ALL
                     SELECT DISTINCT idfo idfund, idkto idaccount FROM fis.fv_kto_trans
                     UNION ALL
                     SELECT DISTINCT trx.idfo idfund, kpl.idkto idaccount
                       FROM fis.fv_kto_trans trx
                       JOIN fis.fvb_kto_plan kpl on kpl.udkto = trx.udgegenkto
                    ) b
                     --dvsweb.vwm_th_fundaccounts b
                     -- add fund hierarchy
                     JOIN dvsweb.VWM_AIS_FUND_HIERARCHY_MATRIX fh
                        ON fh.idfund = b.idfund
                     -- retrieve IDKTOG
                     JOIN FIS.FMT_KTOGOFKTO ktog
                        ON ktog.idkto = b.idaccount
                     JOIN FIS.FV_KTOG_SCHEMA kgs
                        ON ktog.idkgs = kgs.idkgs
                     -- retrieve GL Mapping via account group (IDKTOG) and level groups of a fund
                     JOIN FIS.CUST_FVB_GLMAPPING glm
                        ON glm.idktog = ktog.idktog AND fh.levelgroup = glm.udlevelgroup
                        WHERE glm.isdeleted = 'N'
               AND udkgs = 'COA_ACCOUNTNUMBER');
