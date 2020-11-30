#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/osstat.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : osstat.pl tnsname\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    #print "$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$";

    # $result will be
    # assigned:282
    # free:18
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$`;
    my %osstat  = ();


    # @_ will have
    # $_[0] : IDLE_TIME:282
    # $_[1] : BUSY_TIME:18
    # $_[2] : USER_TIME:192
    @_ =  split('\n',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $osstat{'IDLE_TIME'} will have 10
        # $osstat{'BUSY_TIME'} will have 8
        # $osstat{'USER_TIME'} will have 8
        $osstat{ $str[0] } = $str[1];
    }


    $result = '';

    foreach $key (sort(keys %osstat)) {
        $result .= $key . ":" . $osstat{$key} . " " ;
    }

    $result =~ s/ $//g;

    print $result;

}

sub set_env {
   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}

