#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/recovery_area.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : flashback_space.pl tnsname\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    # $result will be
    # Used:96.43
    # Reclaimable:29.83
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$`;
    my %space  = ();


    # @_ will have
    # $_[0] : assigned:282
    # $_[1] : free:18
    @_ =  split(' ',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $space{'Used'} will have 96.43
        # $space{'Reclaimable'} will have 29.83
        $space{ $str[0] } = $str[1];
    }

    print "used:$space{'used'} reclaimable:" . $space{'reclaimable'};
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
