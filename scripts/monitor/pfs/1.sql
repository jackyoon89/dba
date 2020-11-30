explain plan for 
   SELECT finale."RefDate",
          finale."FundNo",
          finale."AcctNoSystem",
          finale."AcctNo",
          --         "AcctDesc",
          finale."AcctNoMapping",
          --         "Coa",
          finale."Reclass",
          finale."ReclassVoucher",                         /* TH, 11.7.2013 */
          finale."Name",
          finale."BalanceDate",
          finale."Balance" AS "BalanceUnrounded",
          finale."BalanceAdjustment",
          finale."BalanceSource",
          finale."RefDateComparative",
          finale."BalanceDateComparative",
          finale."BalanceComparative",
          finale."BalanceAdjustmentComparative",
          finale."ReclassedBalanceSum",
          --         "BalanceSourceComparative",
          --         "RefDateComparative2",
          --         "BalanceDateComparative2",
          finale."BalanceComparative2",
          --         "BalanceAdjustmentComparative2",
          --         "BalanceSourceComparative2",
          CCY,
          map.lineitem AS "LineItemOriginal",
          map.lineitem_code_old AS "LineItemOriginalCode",
          finale."LineItemMapping",
          finale."LineItemMappingCode",
          finale."LineItemSum",
          finale."LineItemSumComparative",
          finale.rollup_code AS "LineItemRollupCode",
          finale.rollup AS "LineItemRollup",
          finale."LineItemRollupBalance",
          --         finale.notesrollup_code as "LineItemNotesRollupCode",
          --         finale.notesrollup as "LineItemNotesRollup",
          --         finale."LineItemNotesRollupBalance",
          finale."LineItemNettingID",
          Net.LineItem_code_old AS "LineItemNettingCode",
          Net.LineItem AS "LineItemNetting",
          Prc5.LineItem AS "LineItem5PrcRule",
          --"LineitemNetting5Prc"
          --"LineitemNetting5PrcName"
          --"LineItemNoOtherExpenses"
          --"LineItemNegative"
          finale."LineItemGroupIDFinal",
          LIGrp.lineitem AS "LineItemGroup",
          LIGrp.lineitem_code_old AS "LineItemGroupCode",
          LIM.Statement AS "Statement",
          LIM.Statement_Code AS "StatementCode",
          --NULL as "StatementScheme"
          --NULL as "LineItemSchemaLevel"
          --NULL as "LineItemSchemaEntity"
          --NULL as "LineItemSchema"
          --       finale."BalanceContributionToNAV",
          finale."NAV",
          finale."NAVComparative",
          finale."NAVComparative2",
          finale.clearer AS "Clearer",
          finale.clearername AS "ClearerName",
          finale."IDACCOUNT",
          finale.idfund,
          finale."LineItemIDFinal" AS "LineItemID", /* TH, 11.7.2013: required to uniqely identify the line item for taking snapshots */
          LIM.LINEITEM AS "LineItem",
          LIM.LINEITEM_CODE_OLD AS "LineItemCode",
          finale."5PrcRuleActive" AS "Active5PrcRule",
          LIM.subtotal AS "Subtotal",
          LIM.subtotal_code AS "SubtotalCode",
          LIM.subtotal_order AS "SubtotalSort",
          finale.subtotal_code AS "SubtotalMappingCode",
          COMP.LINEITEM AS "LineItemComp",
          COMP.LINEITEM_CODE_OLD AS "LineItemCodeComp",
          COMP.subtotal AS "SubtotalComp",
          SUM (finale."Balance") OVER (PARTITION BY finale.Subtotal_Code)
             AS "SubtotalSum",
          SUM (finale."Balance")
          OVER (PARTITION BY finale."LineItemIDFinal", finale.Statement_Code)
             AS "LineitemFinalSum",
          ROUND (
             SUM (
                finale."Balance")
             OVER (
                PARTITION BY finale."LineItemIDFinal", finale.Statement_Code),
             0)
             AS "LineitemFinalSumRounded",
          --       SUM (finale."BalanceComparative") OVER (PARTITION BY finale."LineItemIDFinal", finale.Statement_Code)     AS "LineitemFinalSumComp",
          LIM.lineitem_order AS "LineItemSort",
          ROUND (finale."Balance", 0) AS "BalanceRounded",
          -- rounding control =======================================================================================================
          --       SUM (ROUND (finale."Balance", 0)) OVER ()     AS "sumBalanceRounded",
          ROUND (SUM (finale."Balance") OVER (), 0) AS "sumBalance",
          --       SUM (ROUND (finale."Balance", 0))            OVER (PARTITION BY finale.Statement_Code)     AS "sumStatementRounded",
          --       ROUND (SUM (finale."Balance")                OVER (PARTITION BY finale.Statement_Code), 0) AS "sumStatementUnrounded",
          --       SUM (ROUND (finale."BalanceComparative", 0)) OVER (PARTITION BY finale.Statement_Code)     AS "sumStatementRoundedComp",
          --       ROUND (SUM (finale."BalanceComparative")     OVER (PARTITION BY finale.Statement_Code), 0) AS "sumStatementUnroundedComp",
          -- others =================================================================================================================
          RANK ()
          OVER (PARTITION BY finale.Statement_Code
                ORDER BY finale."Balance" DESC)
             AS "Rank",
          finale."IsMaster",
          -- active flags  ==========================================================================================================
          finale."NettingActive" AS "ActiveNetting", -- due to compatibility requirements
          finale."NettingActiveComp" AS "ActiveNettingComp", -- due to compatibility requirements
          finale."5PrcRuleActive",
          finale."FXSplitRuleActive",
          finale."NegativeLineItemActive",
          finale."OtherExpensesActive",
          finale."ReclassComment",
          finale.nosmartrounding AS "NoSmartRounding"
     FROM (SELECT netting.*,
                  -- finally remap nettings and 5%-rulers
                  CASE
                     WHEN -- netting w/o 5% rule: either "line item group" of "netting item" or "netting item" itself
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NULL
                     THEN
                        NVL (
                           (SELECT IDLineItemGroup
                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                             WHERE IDLineItem = netting."LineItemNettingID"),
                           netting."LineItemNettingID")
                     WHEN -- netting with 5% rule: either "line item group" of "5% rule item" of "netting item", or "5% rule item" of "netting item" itself
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        NVL (
                           (SELECT IDLineItemGroup
                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                             WHERE IDLineItem =
                                      netting."LineItemNettingPrc5RuleID"),
                           netting."LineItemNettingPrc5RuleID")
                     WHEN -- no netting or positive netting sum and 5% rule on the line item: either "line item group" of "5% rule item" or "5% rule item" itself
                         NVL  (netting."LineItemNettingSum", 0) >= 0
                          AND netting.IDPRC5RULE IS NOT NULL
                          AND ABS (
                                   netting."LineItemSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        NVL ( (SELECT IDLineItemGroup
                                 FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                WHERE IDLineItem = netting.IDPRC5RULE),
                             netting.IDPRC5RULE)
                     ELSE -- either "line item group" of current "line item" or current "line item" itself
                        NVL (
                           (SELECT IDLineItemGroup
                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                             WHERE IDLineItem = netting."LineItemRemappedID"),
                           netting."LineItemRemappedID")
                  END
                     AS "LineItemIDFinal",
                  -- finally remap nettings and 5%-rulers
                  CASE
                     WHEN -- netting w/o 5% rule: either "line item group" of "netting item" or "netting item" itself
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NULL
                     THEN
                        (SELECT IDLineItemGroup
                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                          WHERE IDLineItem = netting."LineItemNettingID")
                     WHEN -- netting with 5% rule: either "line item group" of "5% rule item" of "netting item", or "5% rule item" of "netting item" itself
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        (SELECT IDLineItemGroup
                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                          WHERE IDLineItem =
                                   netting."LineItemNettingPrc5RuleID")
                     WHEN -- no netting or positive netting sum and 5% rule on the line item: either "line item group" of "5% rule item" or "5% rule item" itself
                         NVL  (netting."LineItemNettingSum", 0) >= 0
                          AND netting.IDPRC5RULE IS NOT NULL
                          AND ABS (
                                   netting."LineItemSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        (SELECT IDLineItemGroup
                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                          WHERE IDLineItem = netting.IDPRC5RULE)
                     ELSE -- either "line item group" of current "line item" or current "line item" itself
                        (SELECT IDLineItemGroup
                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                          WHERE IDLineItem = netting."LineItemRemappedID")
                  END
                     AS "LineItemGroupIDFinal",
                  CASE
                     WHEN                               -- netting w/o 5% rule
                         NVL  (netting."LineItemNettingSumComparative",
                               0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NULL
                     THEN
                        NVL (
                           (SELECT IDLineItemGroup
                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                             WHERE IDLineItem = netting."LineItemNettingID"),
                           netting."LineItemNettingID")
                     WHEN                              -- netting with 5% rule
                         NVL  (netting."LineItemNettingSumComparative",
                               0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSumComparative"
                                 / NULLIF (netting."SubtotalSumComp", 0)
                                 * 100) < 5
                     THEN
                        NVL (
                           (SELECT IDLineItemGroup
                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                             WHERE IDLineItem =
                                      netting."LineItemNettingPrc5RuleID"),
                           netting."LineItemNettingPrc5RuleID")
                     WHEN -- no netting or positive netting sum and 5% rule on the line item
                         NVL  (netting."LineItemNettingSumComparative",
                               0) >= 0
                          AND netting.IDPRC5RULE IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSumComparative"
                                 / NULLIF (netting."SubtotalSumComp", 0)
                                 * 100) < 5
                     THEN
                        NVL ( (SELECT IDLineItemGroup
                                 FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                WHERE IDLineItem = netting.IDPRC5RULE),
                             netting.IDPRC5RULE)
                     ELSE
                        NVL (
                           (SELECT IDLineItemGroup
                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                             WHERE IDLineItem = netting."LineItemRemappedID"),
                           netting."LineItemRemappedID")
                  END
                     AS "LineItemIDCompFinal",
                  -- remapping rules flags ==============================================================================================
                  CASE
                     WHEN                               -- netting w/o 5% rule
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NULL
                     THEN
                        'Y'
                     WHEN                              -- netting with 5% rule
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        'Y'
                     ELSE
                        'N'
                  END
                     AS "NettingActive",
                  CASE
                     WHEN                          -- comp netting w/o 5% rule
                         NVL  (netting."LineItemNettingSumComparative",
                               0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NULL
                     THEN
                        'Y'
                     WHEN                         -- comp netting with 5% rule
                         NVL  (netting."LineItemNettingSumComparative",
                               0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSumComparative"
                                 / NULLIF (netting."SubtotalSumComp", 0)
                                 * 100) < 5
                     THEN
                        'Y'
                     ELSE
                        'N'
                  END
                     AS "NettingActiveComp",
                  CASE
                     WHEN                              -- netting with 5% rule
                         NVL  (netting."LineItemNettingSum", 0) < 0
                          AND netting."LineItemNettingPrc5RuleID" IS NOT NULL
                          AND ABS (
                                   netting."LineItemNettingSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        'Y'
                     WHEN -- no netting or positive netting sum and 5% rule on the line item
                         NVL  (netting."LineItemNettingSum", 0) >= 0
                          AND netting.IDPRC5RULE IS NOT NULL
                          AND ABS (
                                   netting."LineItemSum"
                                 / NULLIF (netting."SubtotalSum", 0)
                                 * 100) < 5
                     THEN
                        'Y'
                     ELSE
                        'N'
                  END
                     AS "5PrcRuleActive"
             FROM (SELECT remapped.*,
                          DECODE (
                             remapped."LineItemNettingID",
                             NULL, NULL,
                             SUM (
                                remapped."Balance")
                             OVER (
                                PARTITION BY remapped."LineItemNettingID",
                                             remapped.statement_code))
                             AS "LineItemNettingSum",
                          DECODE (
                             remapped."LineItemNettingID",
                             NULL, NULL,
                             SUM (
                                remapped."BalanceComparative")
                             OVER (
                                PARTITION BY remapped."LineItemNettingID",
                                             remapped.statement_code))
                             AS "LineItemNettingSumComparative"
                     FROM (SELECT agg.*,
                                  -- remapping of FXSplit, Negative line items, Other expenses ==========================================================
                                  CASE
                                     WHEN agg."FXSplitRuleActive" = 'Y'
                                     THEN
                                        agg.IDFXSPLIT
                                     WHEN agg."NegativeLineItemActive" = 'Y'
                                     THEN
                                        agg.IDNEGATIVE_LINEITEM
                                     WHEN agg."OtherExpensesActive" = 'Y'
                                     THEN
                                        agg.IDOTHEREXPENSES
                                     ELSE
                                        agg.IDLINEITEM
                                  END
                                     AS "LineItemRemappedID",
                                  CASE
                                     WHEN agg."FXSplitRuleActive" = 'Y'
                                     THEN
                                        (SELECT IDLINEITEMGROUP
                                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                          WHERE IDLINEITEM = agg.IDFXSPLIT)
                                     WHEN agg."NegativeLineItemActive" = 'Y'
                                     THEN
                                        (SELECT IDLINEITEMGROUP
                                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                          WHERE IDLINEITEM =
                                                   agg.IDNEGATIVE_LINEITEM)
                                     WHEN agg."OtherExpensesActive" = 'Y'
                                     THEN
                                        (SELECT IDLINEITEMGROUP
                                           FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                          WHERE IDLINEITEM =
                                                   agg.IDOTHEREXPENSES)
                                     ELSE
                                        agg."LineItemGroupIDMapping"
                                  END
                                     AS "LineItemGroupID",
                                  -- get Netting line item, depending on remapping rules ================================================================
                                  CASE
                                     WHEN agg."FXSplitRuleActive" = 'Y'
                                     THEN -- use Netting item from FX Split Item, if available
                                        NVL (
                                           (SELECT idnetting
                                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                             WHERE idlineitem = agg.IDFXSPLIT),
                                           agg.IDNETTING)
                                     WHEN agg."NegativeLineItemActive" = 'Y'
                                     THEN -- use Netting from negative line item, if available
                                        NVL (
                                           (SELECT idnetting
                                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                             WHERE idlineitem =
                                                      agg.IDNEGATIVE_LINEITEM),
                                           agg.IDNETTING)
                                     WHEN agg."OtherExpensesActive" = 'Y'
                                     THEN -- use Netting from other expenses line item, if available
                                        NVL (
                                           (SELECT idnetting
                                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                             WHERE idlineitem =
                                                      agg.IDOTHEREXPENSES),
                                           agg.IDNETTING)
                                     ELSE
                                        agg.IDNETTING
                                  END
                                     AS "LineItemNettingID",
                                  -- get Netting line item, depending on remapping rules ================================================================
                                  CASE
                                     WHEN agg."FXSplitRuleActive" = 'Y'
                                     THEN -- use Netting item from FX Split Item, if available
                                        NVL (
                                           (SELECT idnettingprc5rule
                                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                             WHERE idlineitem = agg.IDFXSPLIT),
                                           agg.idnettingprc5rule)
                                     WHEN agg."NegativeLineItemActive" = 'Y'
                                     THEN -- use Netting from negative line item, if available
                                        NVL (
                                           (SELECT idnettingprc5rule
                                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                             WHERE idlineitem =
                                                      agg.IDNEGATIVE_LINEITEM),
                                           agg.idnettingprc5rule)
                                     WHEN agg."OtherExpensesActive" = 'Y'
                                     THEN -- use Netting from other expenses line item, if available
                                        NVL (
                                           (SELECT idnettingprc5rule
                                              FROM DVSWEB.VWM_AIS_LINEITEMMAPPING
                                             WHERE idlineitem =
                                                      agg.IDOTHEREXPENSES),
                                           agg.idnettingprc5rule)
                                     ELSE
                                        agg.idnettingprc5rule
                                  END
                                     AS "LineItemNettingPrc5RuleID"
                             FROM (SELECT b."RefDate",
                                          b."FundNo",
                                          b."AcctNoSystem",
                                          b."AcctNoMapping",
                                          b."AcctNo",
                                          --                   b."AcctDesc",
                                          --                   b."Coa",
                                          b."Reclass",
                                          --                   b."CreditDebit",
                                          b."Name",
                                          b."IDACCOUNT",
                                          b."IDFUND",
                                          b."CCY",
                                          glm.UDFO,
                                          glm.UDDEV AS "FundCCY",
                                          -- reclassification ===========================================================================================
                                          b."ReclassType",
                                          b."ReclassComment",
                                          b."ReclassVoucher",
                                          b."ReclassCanceled",
                                          b."ReclassUser",
                                          b."ReclassChanged",
                                          b."ReclassTypeComp",
                                          b."ReclassCommentComp",
                                          b."ReclassVoucherComp",
                                          b."ReclassCanceledComp",
                                          b."ReclassUserComp",
                                          b."ReclassChangedComp",
                                          -- gl mapping details =========================================================================================
                                          glm.idlineitem
                                             AS "LineItemIDMapping",
                                          glm.lineitem_code_old
                                             AS "LineItemMappingCode",
                                          glm.lineitem AS "LineItemMapping",
                                          glm.idlineitem,
                                          glm.idlineitemgroup
                                             AS "LineItemGroupIDMapping",
                                          glm.statement_code,
                                          glm.subtotal_code,
                                          glm.idfxsplit,
                                          glm.idnegative_lineitem,
                                          glm.idnetting,
                                          glm.idprc5rule,
                                          glm.rollup_code,
                                          glm.rollup,
                                          glm.notesrollup_code,
                                          glm.notesrollup,
                                          glm.no_otherexpense_agg,
                                          glm.negativelncp,
                                          glm.nosmartrounding,
                                          glm.fixedfloat,
                                          glm.idotherexpenses,
                                          glm.idnettingprc5rule,
                                          glm.lineitem_order,
                                          glm.subtotal_order,
                                          glm.Clearer,
                                          glm.ClearerName,
                                          -- balances ===========================================================================================================
                                          b."BalanceDate",
                                          b."Balance",
                                          b."BalanceSource",
                                          b."BalanceAdjustment",
                                          --                   b."BalanceOriginalAdjustment",
                                          b."RefDateComparative",
                                          b."BalanceDateComparative",
                                          b."BalanceComparative",
                                          --                   b."BalanceAdjustmentComparative",
                                          --                   b."BalanceSourceComparative",
                                          --                   b."RefDateComparative2",
                                          --                   b."BalanceDateComparative2",
                                          b."BalanceComparative2",
                                          --                   b."BalanceAdjustmentComparative2",
                                          --                   b."BalanceSourceComparative2",
                                          NVL2 (glm.rollup_code,
                                                b."Balance",
                                                NULL)
                                             AS "LineItemRollupBalance",
                                          --                   NVL2 (glm.notesrollup_code, b."Balance", null) AS "LineItemNotesRollupBalance",
                                          -- calculating SUMs ===================================================================================================
                                          SUM (
                                             b."Balance")
                                          OVER (
                                             PARTITION BY glm.Subtotal_Code)
                                             AS "SubtotalSum",
                                          SUM (
                                             b."BalanceComparative")
                                          OVER (
                                             PARTITION BY glm.Subtotal_Code)
                                             AS "SubtotalSumComp",
                                          SUM (
                                             b."Balance")
                                          OVER (
                                             PARTITION BY glm.IDLineitem,
                                                          glm.Statement_Code)
                                             AS "LineItemSum",
                                          SUM (
                                             b."BalanceComparative")
                                          OVER (
                                             PARTITION BY glm.IDLineitem,
                                                          glm.Statement_Code)
                                             AS "LineItemSumComparative",
                                          --                   SUM (b."Balance")            OVER (PARTITION BY glm.Clearer, glm.IDLineitem, glm.Statement_Code) AS "LineItemClearerSum",
                                          --                   SUM (b."BalanceComparative") OVER (PARTITION BY glm.Clearer, glm.IDLineitem, glm.Statement_Code) AS "LineItemClearerSumComparative",
                                          SUM (
                                             DECODE (
                                                glm.Statement_Code,
                                                'BALANCESHEET', b."Balance",
                                                0))
                                          OVER ()
                                             AS "NAV",
                                          SUM (
                                             DECODE (
                                                glm.Statement_Code,
                                                'BALANCESHEET', b."BalanceComparative",
                                                0))
                                          OVER ()
                                             AS "NAVComparative",
                                          SUM (
                                             DECODE (
                                                glm.Statement_Code,
                                                'BALANCESHEET', b."BalanceComparative2",
                                                0))
                                          OVER ()
                                             AS "NAVComparative2",
                                          --                   DECODE (glm.Statement_Code, 'BALANCESHEET', b."Balance" / SUM (DECODE (glm.Statement_Code, 'BALANCESHEET', b."Balance", 0)) OVER (), NULL) AS "BalanceContributionToNAV",
                                          --                   SUM (b."BalanceAdjustment")             OVER () AS "ReclassedBalance",
                                          SUM (
                                             b."BalanceAdjustmentComparative")
                                          OVER ()
                                             AS "BalanceAdjustmentComparative", --"ReclassedBalanceComparative",
                                          --                   SUM (b."BalanceAdjustmentComparative2") OVER () AS "ReclassedBalanceComparative2",
                                          SUM (
                                             b."BalanceAdjustment")
                                          OVER (
                                             PARTITION BY glm.IDLineitem,
                                                          glm.Statement_Code)
                                             AS "ReclassedBalanceSum",
                                          --                   SUM (b."BalanceAdjustmentComparative")   OVER (PARTITION BY glm.IDLineitem, glm.Statement_Code) AS "ReclassedBalanceComparativeSum",
                                          --                   SUM (b."BalanceAdjustmentComparative2")  OVER (PARTITION BY glm.IDLineitem, glm.Statement_Code) AS "ReclassedBalanceComp2Sum",
                                          -- remapping rules flags ==============================================================================================
                                          CASE
                                             WHEN     glm.IDFXSplit
                                                         IS NOT NULL
                                                  AND glm.UDDEV <> b."CCY"
                                             THEN
                                                'Y'
                                             ELSE
                                                'N'
                                          END
                                             AS "FXSplitRuleActive",
                                          CASE
                                             WHEN    (    SUM (
                                                             b."Balance")
                                                          OVER (
                                                             PARTITION BY glm.IDLineitem,
                                                                          glm.Statement_Code) <
                                                             0
                                                      AND glm.NEGATIVELNCP =
                                                             'N')
                                                  OR -- SUM() see "LineItemSum" above
                                                     (    SUM (
                                                             b."Balance")
                                                          OVER (
                                                             PARTITION BY glm.Clearer,
                                                                          glm.IDLineitem,
                                                                          glm.Statement_Code) <
                                                             0
                                                      AND glm.NEGATIVELNCP =
                                                             'Y') -- SUM() see "LineItemClearerSum" above
                                             THEN
                                                NVL2 (
                                                   glm.IDNEGATIVE_LINEITEM,
                                                   'Y',
                                                   'N')
                                             ELSE
                                                'N'
                                          END
                                             AS "NegativeLineItemActive",
                                          CASE
                                             WHEN     glm.IDOTHEREXPENSES
                                                         IS NOT NULL
                                                  AND SUM (
                                                         b."Balance")
                                                      OVER (
                                                         PARTITION BY glm.IDLineitem,
                                                                      glm.Statement_Code) <
                                                         0 -- negative line item sum AND OTHEREXPENSES set
                                             THEN
                                                'Y'
                                             ELSE
                                                'N'
                                          END
                                             AS "OtherExpensesActive",
                                          -- Others =====================================================================================================
                                          --                   b."IsSleve",
                                          b."IsMaster"
                                     --                   b."IsLookthrough",
                                     --                   b."IsSleveComp",
                                     --                   b."IsMasterComp",
                                     --                   b."IsLookthroughComp",
                                     --                   b."IsSleveComp2",
                                     --                   b."IsMasterComp2",
                                     --                   b."IsLookthroughComp2"
                                     FROM    dvsweb.VW_AIS_BALANCES_COMP b
                                          INNER JOIN
                                             dvsweb.vwb_ais_fund_glmapping glm
                                          ON     glm.idaccount = b.idaccount
                                             AND glm.idfund = b.idfund) agg) remapped) netting) finale
          INNER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING LIM
             ON LIM.IDLINEITEM = finale."LineItemIDFinal"
          INNER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING COMP
             ON COMP.IDLINEITEM = finale."LineItemIDCompFinal"
          LEFT OUTER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING LIGrp
             ON LIGrp.idlineitem = finale."LineItemGroupIDFinal"
          LEFT OUTER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING Net
             ON Net.idlineitem = finale."LineItemNettingID"
          LEFT OUTER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING Map
             ON Map.idlineitem = finale."LineItemRemappedID"
          LEFT OUTER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING Prc5
             ON Prc5.idlineitem = finale.idprc5rule
          LEFT OUTER JOIN DVSWEB.VWM_AIS_LINEITEMMAPPING FXS
             ON FXS.IDLINEITEM = finale.IDFxSplit;
