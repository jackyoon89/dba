select name,password_date from sys.user$ A ,sys.user_history$ B
where A.user# = B.user# 
and A.name = upper('&1')
order by password_date
/
