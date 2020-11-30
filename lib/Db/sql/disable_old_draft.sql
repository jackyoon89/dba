rem
rem File Name : audit_trail_report.sql
rem

set pagesize 500
set line 180
set verify off
set heading off
set serverout on

begin
update whitney.pricing_input
   set is_available = 'N',
       is_active = 'N',
       pricing_input_status = 'CANCELLED',
       last_updated_by = 'Draft Disabling Script',
       last_updated_date = sysdate
 where trade_request_key in
       (
       select trade_request_key
         from whitney.trade_request
        where define_date < add_months(sysdate, -1)
          and is_available = 'Y'
          and is_template = 'N'
       );

dbms_output.put_line( 'Total '||to_char(sql%rowcount)||' draft(s) disabled on pricing_input table.');

update whitney.trade_request
   set is_available = 'N',
       last_updated_by = 'Draft Disabling Script',
       last_updated_date = sysdate
 where define_date < add_months(sysdate, -1)
   and is_available = 'Y'
   and is_template = 'N'
       ;

dbms_output.put_line( 'Total '||to_char(sql%rowcount)||' draft(s) disabled on trade_request table.');
end;
/

exit
