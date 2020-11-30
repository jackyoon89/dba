#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/db_size.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : db_size.pl tnsname\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    #print "$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$";

    # $result will be
    # assigned:282
    # free:18
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$`;
    my %space  = ();


    # @_ will have
    # $_[0] : assigned:282
    # $_[1] : free:18
    @_ =  split('\n',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $space{'assigned'} will have 282
        # $space{'free'} will have 18
        $space{ $str[0] } = $str[1];
    }

    print "assigned:$space{'assigned'} used:" . int($space{'assigned'}-$space{'free'});
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
