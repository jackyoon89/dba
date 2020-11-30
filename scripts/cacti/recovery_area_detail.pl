#!/usr/bin/perl -w


main();

sub main {
    my $sql      = "/home/app/oracle/admin/DBA/scripts/cacti/sql/recovery_area_detail.sql";
    my $username = "crontab/PejWZnQgD0xhnT3tU3gZBQ";


    if ( $#ARGV + 1 != 1 ) {
        print "Usage : recovery_area_detail.pl tnsname\n";
        exit;
    }

    # Set Oracle Environment variables
    set_env();


    # $result will be
    # archivelog:15.37
    # backuppiece:0
    # controlfile:0
    # flashbacklog:0
    # imagecopy:0
    # onlinelog:0
    my $result =`$ENV{ORACLE_HOME}/bin/sqlplus \-s $username\@$ARGV[0] \@$sql|grep \-v \^\$`;
    my %space  = ();


    # @_ will have
    # $_[0] : archivelog:15.37
    # $_[1] : backuppiece:0
    # $_[2] : controlfile:0
    # $_[3] : flashbacklog:0
    # $_[4] : imagecopy:0
    # $_[5] : onlinelog:0
    @_ =  split('\n',$result );

    foreach ( @_ ) {
        my @str = split(':', $_ );

        # $space{'archivelog'} will have 15.37
        # $space{'backuppiece'} will have 0
        # $space{'controlfile'} will have 0
        # $space{'flashbacklog'} will have 0
        # $space{'imagecopy'} will have 0
        # $space{'onlinelog'} will have 0
        $space{ $str[0] } = $str[1];

    }

    print "archivelog:$space{'archivelog'} " .
          "backuppiece:$space{'backuppiece'} " .
          "controlfile:$space{'controlfile'} " .
          "flashbacklog:$space{'flashbacklog'} " .
          "imagecopy:$space{'imagecopy'} " .
          "onlinelog:$space{'onlinelog'}";
}

sub set_env {

   $ENV{ORACLE_HOME} = '/home/app/oracle/product/10g';
   $ENV{LD_LIBRARY_PATH} = '$ENV{ORACLE_HOME}/lib';

}
