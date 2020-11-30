set echo on
set verify off

update whitney.trade t1
  set (PRICING_ROUND_KEY, CUSTOMER_KEY, REQUESTING_USER_KEY, TRADE_ID, CUSTOMER_TRADE_TAG, BASE_CURRENCY_CODE, TERMS_CURRENCY_CODE, TRADE_DATE, BUY_SELL, ENTERED_AMOUNT, TRADE_TYPE_CODE, DERIVED_AMOUNT, ESTIMATED_USD_AMOUNT, IS_BASE_SPECIFIED, TENOR_CODE, VALUE_DATE, FAR_ENTERED_AMOUNT, FAR_DERIVED_AMOUNT, FAR_TENOR_CODE, FAR_VALUE_DATE, WINNING_RATE, WINNING_POINTS, PRICING_USER_KEY, TRADE_STATUS, ADDITIONAL_TERMS, LAST_UPDATED_BY, LAST_UPDATED_DATE_TIME, DEFINED_FIELDS_COMPLETE, PARENT_TRADE_KEY, IS_DELIVERABLE, PENDING_ACTION, PB_TRADE_KEY, DAY_COUNT_CONVENTION, BANK_TRADE_ID, WINNING_FAR_POINTS, HOW_TRADE_CREATED, STAGED_ORDER_KEY, TRADE_TIMESTAMP, IS_CUSTOMER_AGGRESSOR, BANK_KEY, FUND_SUBSIDIARY_KEY, INSTRUMENT_KEY, HOW_TRADE_CANCELLED, BANK_CATEGORY, CUSTOMER_CATEGORY, PRICING_TYPE, EXECUTION_TREASURY_STATUS, PRICE_BASIS, ACCRUED_INTEREST, IS_ROLLED_TRADE, TAKER_STAGED_ORDER_ID, TREASURY_ANNOUNCEMENT_KEY, POSITION_ID, POSITION_TYPE, TRADE_GROUP_KEY, IR_SWAP_SECURITY_ID_KEY, CTI, ORIGIN, TRADE_REQUEST_KEY, TRADE_TIMESTAMP_MILLIS) = (select PRICING_ROUND_KEY, CUSTOMER_KEY, REQUESTING_USER_KEY, TRADE_ID, CUSTOMER_TRADE_TAG, BASE_CURRENCY_CODE, TERMS_CURRENCY_CODE, TRADE_DATE, BUY_SELL, ENTERED_AMOUNT, TRADE_TYPE_CODE, DERIVED_AMOUNT, ESTIMATED_USD_AMOUNT, IS_BASE_SPECIFIED, TENOR_CODE, VALUE_DATE, FAR_ENTERED_AMOUNT, FAR_DERIVED_AMOUNT, FAR_TENOR_CODE, FAR_VALUE_DATE, WINNING_RATE, WINNING_POINTS, PRICING_USER_KEY, TRADE_STATUS, ADDITIONAL_TERMS, LAST_UPDATED_BY, LAST_UPDATED_DATE_TIME, DEFINED_FIELDS_COMPLETE, PARENT_TRADE_KEY, IS_DELIVERABLE, PENDING_ACTION, PB_TRADE_KEY, DAY_COUNT_CONVENTION, BANK_TRADE_ID, WINNING_FAR_POINTS, HOW_TRADE_CREATED, STAGED_ORDER_KEY, TRADE_TIMESTAMP, IS_CUSTOMER_AGGRESSOR, BANK_KEY, FUND_SUBSIDIARY_KEY, INSTRUMENT_KEY, HOW_TRADE_CANCELLED, BANK_CATEGORY, CUSTOMER_CATEGORY, PRICING_TYPE, EXECUTION_TREASURY_STATUS, PRICE_BASIS, ACCRUED_INTEREST, IS_ROLLED_TRADE, TAKER_STAGED_ORDER_ID, TREASURY_ANNOUNCEMENT_KEY, POSITION_ID, POSITION_TYPE, TRADE_GROUP_KEY, IR_SWAP_SECURITY_ID_KEY, CTI, ORIGIN, TRADE_REQUEST_KEY, TRADE_TIMESTAMP_MILLIS from whitney.trade@&&1 t2 where t1.trade_key = t2.trade_key)
where t1.trade_key in (select trade_key 
                         from (select * from whitney.trade@&&1
                                where trade_timestamp between sysdate - 20/1660 and sysdate - 10/1660
                                minus
                               select * from whitney.trade
                                where trade_timestamp between sysdate - 20/1660 and sysdate - 10/1660)
                       )
/

commit;

exit