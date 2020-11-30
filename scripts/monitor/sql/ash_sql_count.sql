select SQL_ID, count(*) from dba_hist_active_sess_history
group by sql_id
order by 2
/
