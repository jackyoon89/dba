#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/asm_io.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 2 ) {
        print "Usage : asm_io.pl tnsname disk_group_name\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    # $result will be
    # bytes_read:9330756 bytes_write:1425079 bytes_per_read:12679 bytes_per_write:12333
    #
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql $ARGV[1]|grep \-v \^\$`;
    my %io     = ();


    # @_ will have
    # $_[0] : assigned:282
    # $_[1] : free:18
    @_ =  split(' ',$result );

    foreach ( @_ ) {
  
        my @str = split(':', $_ );

        # $io{'bytes_read_per_sec'} will have 2259260
        # $io{'bytes_write_per_sec'} will have 1361736
        # $io{'bytes_per_read'} will have 1361736
        # $io{'bytes_per_write'} will have 1361736
        $io{ $str[0] } = $str[1];
    }

    print "bytes_read_per_sec:$io{'bytes_read'} bytes_write_per_sec:$io{'bytes_write'} bytes_per_read:$io{'bytes_per_read'} bytes_per_write:$io{'bytes_per_write'}";
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
