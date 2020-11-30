select  name, value, to_number(substr(value,2,2))*24*60 + to_number(substr(value,5,2))*60 + to_number(substr(value,8,2)) ||'.'|| to_number(substr(value,11,2)) lag_min from v$dataguard_stats
where name in ('transport lag','apply lag')
/

