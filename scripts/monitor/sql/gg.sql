connect crontab/PejWZnQgD0xhnT3tU3gZBQ
 
insert into WHITNEY.MTF_PRICING_ROUND
    select * from WHITNEY.MTF_PRICING_ROUND@P01INST_OLTP a
    where exists (select 'x' from whitney.pricing_round b
                  where a.pricing_round_key = b.pricing_round_key)
        minus
   select * from WHITNEY.MTF_PRICING_ROUND
/


insert into WHITNEY.PRICING_ROUND
select * from WHITNEY.PRICING_ROUND@P01INST_OLTP
where pricing_round_key in (
select pricing_round_key from WHITNEY.MTF_PRICING_ROUND@P01INST_OLTP 
minus
select pricing_round_key from WHITNEY.MTF_PRICING_ROUND)
/

insert into WHITNEY.PRICING_INPUT
select * from WHITNEY.PRICING_INPUT@P01INST_OLTP
where pricing_input_key in (select pricing_input_key 
                             from WHITNEY.PRICING_ROUND@P01INST_OLTP
                             where pricing_round_key in (
                                  select pricing_round_key from WHITNEY.MTF_PRICING_ROUND@P01INST_OLTP 
                                   minus
                                  select pricing_round_key from WHITNEY.MTF_PRICING_ROUND)
                            )
/


insert into WHITNEY.TRADE_REQUEST
select * from WHITNEY.TRADE_REQUEST@P01INST_OLTP
where trade_request_key in (select trade_request_key 
                             from WHITNEY.PRICING_INPUT@P01INST_OLTP
                            where pricing_input_key in (select pricing_input_key 
                                                         from WHITNEY.PRICING_ROUND@P01INST_OLTP
                                                        where pricing_round_key in (
                                                               select pricing_round_key from WHITNEY.MTF_PRICING_ROUND@P01INST_OLTP 
                                                               minus
                                                               select pricing_round_key from WHITNEY.MTF_PRICING_ROUND)
                                                      )
                          )
/
