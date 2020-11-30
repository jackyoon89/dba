
create table tg1
    as
    select trade_group_key from whitney.trade_group@fxpret
    minus
    select trade_group_key from whitney.trade_group
    /

select count(*) from tg1;

insert into whitney.trade_group
select * from whitney.trade_group@fxpret
 where trade_group_key in (select * from tg1);


drop table trade_key
/

create table trade_key
as
select trade_key from whitney.trade@fxpret where trade_date > to_date('2016/05/14','yyyy/mm/dd')
minus
select trade_key from whitney.trade  where trade_date > to_date('2016/05/14','yyyy/mm/dd')
/

select count(*) from trade_key;

drop table tg1
/

create table tg1
as
select trade_group_key from whitney.trade_group@fxpret
 where trade_group_key in (select trade_group_key from whitney.trade@fxpret
                             where trade_key in (select * from trade_key))
minus
select trade_group_key from whitney.trade_group
 where last_updated_date_time >  to_date('2016/05/14','yyyy/mm/dd')
/

select count(*) from tg1;

insert into whitney.trade_group
select * from whitney.trade_group@fxpret r
where r.trade_group_key in (select * from tg1)
and not exists (select *
                   from whitney.trade_group l
                  where l.trade_group_key = r.trade_group_key)
/


create table trade_request_key
as
select trade_request_key from whitney.pricing_input@fxpret
  where pricing_input_key in  (select * from pricing_input_key)
minus
select trade_request_key from whitney.pricing_input
  where last_updated_date > to_date('2016/05/15','yyyy/mm/dd')
/

insert into whitney.trade_request
select * from whitney.trade_request@fxpret r
 where trade_request_key in (select * from trade_request_key)
   and not exists (select 'x' from whitney.trade_request l
                     where l.trade_request_key = r.trade_request_key)
/


drop table pricing_input_key
/

create table pricing_input_key
as
select pricing_input_key from whitney.pricing_round@fxpret
 where pricing_round_key in (select * from pricing_round_key)
minus
select pricing_input_key from whitney.pricing_round
 where pricing_round_date  > to_date('2016/05/15','yyyy/mm/dd')
/

select count(*) from pricing_input_key
/


insert into whitney.pricing_input
select * from  whitney.pricing_input@fxpret r
where  pricing_input_key in (select * from pricing_input_key)
  and not exists (select 'x' from whitney.pricing_input l
                   where r.pricing_input_key = l.pricing_input_key)
/


drop table pricing_round_key
/

create table pricing_round_key
as
select pricing_round_key from whitney.trade@fxpret
 where trade_key in (select * from trade_key)
minus
select pricing_round_key from whitney.trade
where trade_date > to_date('2016/05/15','yyyy/mm/dd')
/

insert into whitney.pricing_round
select * from whitney.pricing_round@fxpret r
where pricing_round_key in (select * from pricing_round_key)
  and not exists (select 'x' from whitney.pricing_round l
                   where r.pricing_round_key = l.pricing_round_key)
/


create table trade_key
as 
select trade_key from whitney.trade@fxpret
minus
select trade_key from whitney.trade
/

insert into whitney.trade
select * from whitney.trade@fxpret where TRADE_key in (select * from trade_key);



