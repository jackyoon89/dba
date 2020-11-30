set serveroutput on

BEGIN
whitney.delete_terminated_package.update_terminated;
whitney.delete_terminated_package.update_terminated_user;
END;
/
commit;

exit
