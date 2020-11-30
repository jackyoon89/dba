set line 180
col table_name format a30
col NUM_ROWS format 999,999,999,999
col BLOCKS format 999,999,999,999
col EMPTY_BLOCKS format 999,999,999,999
col AVG_SPACE format 999,999,999,999
col AVG_ROW_LEN format 999,999,999,999


select table_name, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE,  AVG_ROW_LEN, LAST_ANALYZED 
from dba_tables
where owner = upper('&1')
  and table_name = upper('&2')
/
