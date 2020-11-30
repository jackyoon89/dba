accept sql_id prompt 'SQL_ID: '

rem column address new_value address_var
rem column hash_value new_value hash_value_var

select address, hash_value from v$sqlarea where sql_id = '&sql_id';

accept address prompt 'Address:'
accept hash_value prompt 'Hash_value:'

exec dbms_shared_pool.purge('&address,&hash_value', 'c');

