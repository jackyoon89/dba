declare 
    drop_result pls_integer;
begin 
    drop_result := DBMS_SPM.DROP_SQL_PLAN_BASELINE( 
                        sql_handle => '&sql_handle',  
                        plan_name => '&plan_name'); 
    dbms_output.put_line(drop_result);    
end; 
/
