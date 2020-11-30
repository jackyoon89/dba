set timing on
set serverout on

begin
  mig_alz.mig_cleanup_pkg.run_cleanup(1,
                              to_date('01.01.2012','dd.mm.yyyy'),
                              to_date('31.01.2012','dd.mm.yyyy'),
                              true, true);
end;
/

