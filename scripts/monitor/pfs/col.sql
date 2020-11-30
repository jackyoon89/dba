select column_name, NUM_NULLS, NUM_BUCKETS, NUM_DISTINCT from all_tab_columns where table_name = upper('&1');

