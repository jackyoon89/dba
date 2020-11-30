set line 180
set pagesize 800

alter session set current_schema=FIS;

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
                     UNION
                     SELECT DISTINCT idfo idfund, idkto idaccount FROM fis.fv_kto_trans
                     UNION
                     SELECT DISTINCT trx.idfo idfund, kpl.idkto idaccount
                       FROM fis.fv_kto_trans trx
                       JOIN fis.fvb_kto_plan kpl on kpl.udkto = trx.udgegenkto
                    ) b,
                    dvsweb.VWM_AIS_FUND_HIERARCHY_MATRIX fh,
                    FIS.FMT_KTOGOFKTO ktog,
                    FIS.FV_KTOG_SCHEMA kgs,
                    FIS.CUST_FVB_GLMAPPING glm
              WHERE fh.idfund = b.idfund
                AND ktog.idkto = b.idaccount
                AND ktog.idkgs = kgs.idkgs
                AND glm.idktog = ktog.idktog 
                AND fh.levelgroup = glm.udlevelgroup
                AND glm.isdeleted = 'N'
                AND udkgs = 'COA_ACCOUNTNUMBER'); 

