#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/tablespace_size.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : tablespace_size.pl tnsname\n";
        exit;
    }

    my $tnsname = $ARGV[0];


    # Set Oracle Environment variables
    set_env();


    # $result will be
    # assigned:282
    # free:18

    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$tnsname \@$sql|grep \-v \^\$`;
    my %tblsp  = ();


    # @_ will have
    # $_[0] : assigned:282
    # $_[1] : free:18
    @_ =  split('\n',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $tblsp{'assigned'} will have 282
        # $tblsp{'free'} will have 18
        $tblsp{ $str[0] } = $str[1];
    }

    my $return_val = '';

    foreach my $tblsp_name ( sort keys %tblsp ) {
        $return_val .= $tblsp_name . ":" . $tblsp{ $tblsp_name } . " ";
    }

    print $return_val;
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
