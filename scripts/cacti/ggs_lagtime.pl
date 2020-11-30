#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/ggs_lagtime.sql";
    my $auth = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : ggs_lagtime.pl tnsname\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    # $result will be
    # Used:96.43
    # Reclaimable:29.83
    my $result = `$ENV{ORACLE_HOME}/bin/sqlplus \-s $auth\@$ARGV[0] \@$sql`;
    $result =~ s/^\s+//g;

    print "lagtime:$result";
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
