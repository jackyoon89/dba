#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/logswitches.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : logswitches.pl tnsname\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    #print "$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$";

    # $result will be
    # assigned:282
    # free:18
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$`;
    my %logswitches  = ('thread1' => 0, 'thread2' => 0);


    # @_ will have
    # $_[0] : thread1:22
    # $_[1] : thread2:18
    @_ =  split('\n',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $logswitches{'instance1'} will have 10
        # $logswitches{'instance2'} will have 8
        $logswitches{ $str[0] } = $str[1];
    }


    $result = '';

    foreach $key (sort(keys %logswitches)) {
        $result .= $key . ":" . $logswitches{$key} . " " ;
    }

    $result =~ s/ $//g;

    print $result;

}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
