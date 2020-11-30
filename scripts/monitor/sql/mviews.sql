set line 180
col owner format a30
col mview_name format a30

select owner, mview_name, LAST_REFRESH_DATE, LAST_REFRESH_END_TIME, REFRESH_METHOD, REFRESH_MODE from dba_mviews;

