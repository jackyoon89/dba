#!/usr/bin/perl -w
#
# jyoon         2008/12/02      Package moved under Sys::SYSTEM 
# jyoon         2008/03/25      Package Created
#

package Sys::SYSTEM;

use Util::UTIL;

my $DATE   = "/bin/date";
my $UPTIME = "/usr/bin/uptime";

my %STATUS = ( 'FAILED',  0,
               'SUCCEED', 1 );


sub new {

	my $class = shift;

	my $obj = { _current_time => undef,
		    _uptime => undef 
                   };

	bless $obj , $class;

	return $obj;
}

# -------------------------------------------------------------------------------
# Name   : log_sys_load
# Purpose: logs system load average for the daily report purpose
# Return : N/A
# -------------------------------------------------------------------------------
sub log_sys_load {

        my ( $self, $logfile ) = @_;

        $self->{_current_time} = `$DATE '+%Y/%m/%d %H:%M:%S'`;

        chomp $self->{_current_time};

        $_ = `$UPTIME`;

        ( $self->{_uptime} ) = /average: (([0-9]+\.[0-9]+)\, ([0-9]+\.[0-9]+)\, ([0-9]+\.[0-9]+))/;

        open ( FILE, ">>$logfile" ) or die "Cannot open the file $logfile.\n";

        printf( FILE "$self->{_current_time}  $self->{_uptime}\n" );

        close FILE;
}

