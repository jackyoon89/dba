explain plan for
 SELECT /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */
             DISTINCT
             IDFUND,
             IDACCOUNT,
             IDKTOG,
             FIRST_VALUE (UDLEVELGROUP)
                OVER (PARTITION BY IDFUND, IDACCOUNT, IDKTOG ORDER BY PRIORITY ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                AS LEVELGROUP
        FROM (        
        SELECT b.idfund,
                     b.idaccount,
                     ktog.idktog,
                     glm.udlevelgroup,
                     fh.priority
                FROM -- all fund/account pairs from balances and transactions
                    (SELECT idfo as idfund, idkto     as idaccount FROM fis.ft_ktostand  ---fv_kto_stand
                     UNION ALL
                     SELECT idfo as idfund, idkto     as idaccount FROM fis.FT_KTOTRANS    ---fv_kto_trans
                     UNION ALL
                     SELECT trx.idfo as idfund, kpl.idkto as idaccount FROM fis.FT_KTOTRANS trx ---fvb_kto_trans trx
                       JOIN fis.FT_KTOPLAN  kpl on kpl.udkto = trx.udgegenkto ---fvb_kto_plan
                    ) b
                     -- add fund hierarchy
                     JOIN dvsweb.VWM_AIS_FUND_HIERARCHY_MATRIX fh ON fh.idfund = b.idfund
                     -- retrieve IDKTOG
                     JOIN FIS.FMT_KTOGOFKTO ktog ON ktog.idkto = b.idaccount
                     JOIN FIS.FT_KTOGSCHEMA kgs ON ktog.idkgs = kgs.idkgs   ---FV_KTOG_SCHEMA ---> FVB_KTOG_SCHEMA
                     -- retrieve GL Mapping via account group (IDKTOG) and level groups of a fund
                     JOIN FIS.CUST_GLMAPPING glm ON glm.idktog = ktog.idktog AND fh.levelgroup = glm.udlevelgroup ---CUST_FVB_GLMAPPING
                        WHERE glm.isdeleted = 'N'
                          AND kgs.udkgs = 'COA_ACCOUNTNUMBER'
                              ) ;
