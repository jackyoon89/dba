#!/usr/bin/perl -w
# $Header: /home/app/oracle/admin/DBA/crontab/report/system_stat.pl,v 1.0  2007/01/17 jyoon Exp $
# 
# system_stat.pl 
#
# jyoon		2008/12/17 - Started OOP
# jyoon		2007/01/17 - Created
# 
# 1. Disk occupancy
# 2. Network Statistics
# 3. Load Average
#
use lib '/home/app/oracle/admin/DBA/lib';

use Util::UTIL;
use Db::CONFIG;

$NETSTAT = '/bin/netstat';
$GREP    = '/bin/grep';
$DF      = '/bin/df';

main();

sub main {

	my $htmlStr = '';

	my $config = new Db::CONFIG();

	$config->setDbEnv();

	$htmlStr  = GetHeader();
	$htmlStr .= GetDiskUsage();
	$htmlStr .= GetNetStat();
	$htmlStr .= GetNetstat_I();
	$htmlStr .= SysLoadAvg();

	print $htmlStr;

}


# -------------------------------------------------------------------------------
# Name   : GetHeader
# Purpose: Generate header information
# Return : html String
# -------------------------------------------------------------------------------
sub GetHeader {
	my $html = '';

	my $hostname = Util::UTIL::getHostname();
	my $currDate = Util::UTIL::getDateStr();

	$html = "<FONT SIZE=\"5\" FACE=\"Arial\" COLOR=\"#FF0000\"><B>SYSTEM MONITORING REPORT ( $hostname : $currDate )</B></FONT>"	;

	return $html;
}

# -------------------------------------------------------------------------------
# Name   : sysloadavg 
# Purpose: Generate html for System load average
# Return : html string
# -------------------------------------------------------------------------------
sub SysLoadAvg {
	my $html  = '';
	my @htmlTable = ("Date", "Time", "For Last 1 Min", "For Last 5 Min", "For Last 15 Min" );

	my $MONITOR_DIR = "$ENV{ORACLE_BASE}/admin/DBA/crontab/scripts";

	my $filename = "$MONITOR_DIR/log/log_sys_load.log";

	open ( OUT, "$filename" ) 
          or die "Cannot open file $MONITOR_DIR/log/log_sys_load.log.\n";
	
	$html  = "<FONT SIZE=\"2\" FACE=\"Arial\">\n"; 
        $html .= "<H3>SYSTEM LOAD AVERAGE SINCE LAST 24 HOURS</H3></FONT>\n";

	while ( <OUT> ) {
		@_ = split ( /\s+/, $_ );
		push @htmlTable, @_ ;
	}

        $html .= "<FONT FACE=\"Arial\" SIZE=\"2\">\n";
	$html .= GetHtmlTable( 5 , @htmlTable );
	$html .= "</FONT>\n";
	close OUT;

	rename $filename, "$filename.BAK";
	return $html;
}

# -------------------------------------------------------------------------------
# Name   : GetNetStat
# Purpose: Generate html for NetStat
# Return : html string
# -------------------------------------------------------------------------------
sub GetNetstat_I {
	my $html = '';
	my $lineoutput = '';
	my @lineParsed = ();
	my @statusTable = ();

	$_ = `$NETSTAT -i|$GREP ^[beIl]|$GREP -v :`;
	@_ = split ( /\n/ , $_ );

	while ( defined( $lineoutput = shift @_ )) {
		@lineParsed = split ( /\s+/ , $lineoutput ) ;
		push @statusTable, @lineParsed;
	}
	
	$html  = "<FONT SIZE=\"2\" FACE=\"Arial\">";
        $html .= "<H3>Ethernet Card Statistics</H3>";
        $html .= "</FONT>";
        $html .= "<FONT FACE=\"Arial\" SIZE=\"2\">";
        $html .= GetHtmlTable( 12 , @statusTable );
        $html .= "</FONT>\n";

	return $html;
}

# -------------------------------------------------------------------------------
# Name   : GetNetStat
# Purpose: Generate html for NetStat
# Return : html string
# -------------------------------------------------------------------------------
sub GetNetStat {
	my $html = '';
	my $lineoutput   = '';
	my @lineParsed   = ();
	my %statusHolder = ();
	my @statusTable  = ();
	my @keys = ();
	my @values = ();

	$_ = `$NETSTAT|$GREP ^[a-z]|$GREP -v DGRAM`;
	@_ = split ( /\n/ , $_ );
	
	while ( defined ($lineoutput = shift @_ )) {

		@lineParsed = split ( /\s+/, $lineoutput );    # Parse the line and put the tokens into the array

		if ( defined $statusHolder{ $lineParsed[ 5 ] } ) {
			$statusHolder{ $lineParsed [ 5 ] } += 1;    # Increase it's status to the hash value
		} else {
			$statusHolder{ $lineParsed [ 5 ] } = 1;     # New connection status
		}
	}

	$html  = "<FONT SIZE=\"2\" FACE=\"Arial\">\n";
	$html .= "<H3>Network Statistics</H3>\n";
	$html .= "<LI><B>ESTABLISHED</B> - The socket has an established connection.\n";
	$html .= "<LI><B>TIME_WAIT</B> - The socket is waiting after close to handle packets still in the network.\n";
	$html .= "<LI><B>CLOSE_WAIT</B> - The remote end has shut down, waiting for the socket to close.\n";
	$html .= "</FONT>\n";
	$html .= "<FONT FACE=\"Arial\" SIZE=\"2\">\n";

	foreach my $key ( sort keys %statusHolder ) {
		push @keys, $key;
		push @values, $statusHolder{$key};
	}
	@statusTable = ( @keys , @values );
	
	$html .= GetHtmlTable( $#keys + 1 , @statusTable );
	$html .= "</FONT>\n";

	return $html;
}

# -------------------------------------------------------------------------------
# Name   : GetDiskUsage
# Purpose: Generate html for disk usage 
# Return : html string
# -------------------------------------------------------------------------------
sub GetDiskUsage {
	my $html = '';
	my $rows = 0;
	my @tmpout = ();
	my @output = ("Filesystem", "1k-blocks", "Used", "Available", "Use%", "Mounted on");

	$_ = `$DF -k|$GREP -v ^Filesystem|$GREP -v ^\$`;  # Put the result into $_
	@_ = split ( /\n/ , $_ );                      # Take out \n value and put the result into @_
	
	$rows = $#_ + 1;                              
	
	for ( my $i = 0 ; $i < $rows ; $i++ ) {
		$_ = shift @_ ;
		@tmpout = split ( ' ', $_ );           # Take out ' ' and put them into array
		push @output, @tmpout;
	}
	
	$html  = "<FONT SIZE=\"2\" FACE=\"Arial\">";
	$html .= "<H3>Disk Usage</H3>";
	$html .= "<LI><B>Report filesystem disk space usage</B>";
	$html .= "</FONT>";
	$html .= "<FONT FACE=\"Arial\" SIZE=\"2\">";
	$html .= GetHtmlTable( 6 , @output ) ;         # Will generate html table with 6 columns
	$html .= "</FONT>\n";
	return $html;	
}

# -------------------------------------------------------------------------------
# Name   : GetHtmlTable
# Purpose: Generate html table from array
# Return : $htmlTable
# -------------------------------------------------------------------------------
sub GetHtmlTable {
	my $val = '';
	my $htmlTable = '';
	my $columns = shift @_ ;

	$htmlTable = "<TABLE BORDER=1 CELLPADDING=5>\n<TR>";

	for ( my $i = 0; $i < $columns ; $i++ ) {
		$val = shift @_ ;
		$htmlTable .= "<TD ALIGN=\"LEFT\" BGCOLOR=\"#CCCC99\">";
		$htmlTable .= "<FONT FACE=\"Arial\" SIZE=\"2\"><B>$val</B></FONT></TD>\n";	
	}
	$htmlTable .= "</TR>";

	for ( my $i = 0; $i <= $#_; $i++ ) {
		if ( $i % $columns == 0 ) { $htmlTable .= "<TR>";  } 
		if ( $i % $columns == $columns - 1 ) {      
			$htmlTable .= "<TD ALIGN=\"RIGHT\"><FONT FACE=\"Arial\" SIZE=\"2\">$_[$i]</FONT></TD>\n";
			$htmlTable .= "</TR>\n";            # Last column then close the line
		} else {
			$htmlTable .= "<TD ALIGN=\"RIGHT\"><FONT FACE=\"Arial\" SIZE=\"2\">$_[$i]</FONT></TD>\n";
		}
	}
	
	$htmlTable .= "</TABLE><BR><BR>";
		
	return $htmlTable;
}





