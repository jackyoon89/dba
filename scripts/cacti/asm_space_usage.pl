#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/asm_space_usage.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 2 ) {
        print "Usage : asm_space_usage.pl tnsname disk_group_name\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    # $result will be
    # total_mb:2259260 free_mb:1361736 usable_file_mb:1361736
    #
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql $ARGV[1]|grep \-v \^\$`;
    my %space  = ();


    # @_ will have
    # $_[0] : total_mb:282
    # $_[1] : used_mb:18
    @_ =  split(' ',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $space{'total_mb'} will have 2259260
        # $space{'used_mb'} will have 1361736
        $space{ $str[0] } = $str[1];
    }

    print "total_gb:$space{'total_gb'} used_gb:$space{'used_gb'}";
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
