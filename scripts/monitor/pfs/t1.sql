rem  select /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */ 

explain plan for
select /*+ opt_param('optimizer_index_caching',100) opt_param('optimizer_index_cost_adj',1) */ 
         "AcctNo" as AccountNumber,
         "AcctNoSystem" as AccountId,
         "FundCode",
         "CCY",
         "Name",
         "Balance" 
    from dvsweb.vw_ais_fund_accounts order by ACCOUNTID
/

