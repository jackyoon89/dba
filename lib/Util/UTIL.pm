# # $Header: /home/app/oracle/admin/DBA/lib/Util.pm,v 1.0  2007/01/17 jyoon Exp $
# 
# Util.pm 2007/01/17 Jack Yoon (jack.yoon@currenex.com)
#
# ypesin	2008/03/18 - Changed SendAlert - added one more "Recipient"
# jyoon		2007/04/26 - Package moved under Util::UTIL
# jyoon		2007/04/26 - Changed SendAlert ( Add Additional parameter Recipient )
#			     1. Add Additional parameter "Recipient"
#                            2. Add %Recipient hash variable to make flexible email alert 
# jyoon		2007/01/17 - Created

 
package Util::UTIL;

use Net::SMTP;
use MIME::Lite;
use XML::Simple;
use Config::INI::Simple;



my $DATE = "/bin/date";

my $HWM      = 0;              # HWM for the system load average check

# -------------------------------------------------------------------------------
# Name   : SendAlert
# Purpose: Send Email alert to the predefined list of persons.
# parameters : $_[0]: Mail_Type ( TEXT / HTML )
#              $_[1]: Subject 
#              $_[2]: Recipient
#              $_[3]: Payload
# Return : n/a
# -------------------------------------------------------------------------------
sub SendAlert {

	my ( $mailType, $recipient, $subject, $payload ) = @_;

        my $file = "/home/app/oracle/admin/DBA/config/notification.xml";

        my $xsl    = XML::Simple->new();
	my $config = $xsl->XMLin($file);

        my @TO   = split(/,/,$config->{group}->{lc($recipient)}) ;
        my $FROM = $config->{mailfrom};
        #my $hostname = `hostname --fqdn`;
        #chomp($hostname);
        #my $FROM = "oracle@" . $hostname;


	foreach my $TO ( @TO ) {

        	$smtp = Net::SMTP->new( $config->{mailhost} );

        	$smtp->mail( "$FROM" );
        	$smtp->to("$TO");
        	$smtp->data();
        	$smtp->datasend("To: $TO\n");
        	$smtp->datasend("From: $FROM\n");
        	$smtp->datasend("Subject: $subject\n");

		if ( $mailType eq 'HTML') {
			$smtp->datasend("Content-type: text/html\n");
		}

        	$smtp->datasend("\n");

        	$smtp->datasend("$payload");
        	$smtp->datasend("\n");
        	$smtp->dataend();
        	$smtp->quit();
	}
}

sub send_mail {
    my ( $recipient, $subject, $message, @attachments ) = @_;

    my $file = "/home/app/oracle/admin/DBA/config/notification.xml";
    my $xsl    = XML::Simple->new();
    my $config = $xsl->XMLin($file);

    my $MAILHOST = $config->{mailhost};
    my $TO       = $config->{group}->{lc($recipient)};
    #my $FROM     = $config->{mailfrom};
    my $FROM = `hostname --fqdn`;


    my $msg = MIME::Lite->new (
        From    => $FROM,
        To      => $TO,
        Subject => $subject,
        Type    => 'multipart/mixed',
    );

    $msg->attach ( 'Type' => 'TEXT',
                   'Data' => $message);

    foreach ( @attachments ) {
    $msg->attach ( 'Type'     => 'application/octest-stream',
                   'Encoding' => 'base64',
                   'Path'     => $_ );
    }

    $msg->send;
}


# -------------------------------------------------------------------------------
# Name   : getHWM
# Purpose: To get the High Water Mark of load avg.
# Return : $HWM value
# -------------------------------------------------------------------------------
sub getHWM {
	return $HWM;
}

# -------------------------------------------------------------------------------
# Name   : getHostname
# Purpose: Returns hostname after take out return character
# Return : $hostname
# -------------------------------------------------------------------------------
sub getHostname {
	my $hostname = `/bin/hostname`;
	chomp $hostname;

	return $hostname;
}

# -------------------------------------------------------------------------------
# Name   : getDateStr
# Purpose: Returns Date String after take out return character
# Return : $dateStr
# -------------------------------------------------------------------------------
sub getDateStr {
	my $dateStr = `$DATE '+%Y/%m/%d %H:%M:%S'`;

	chomp $dateStr;

	return $dateStr;
}

# -------------------------------------------------------------------------------
# Name   : getDayNameUnx
# Purpose: Returns Real Date String after take out return character
# Return : $dateStrUnx
# -------------------------------------------------------------------------------
sub getDayNameUnx {
        # 2012/10/17 - jyoon : fixed
	#my $DayName = substr((localtime()),0,11);
	#chomp $DayName;

	chomp(my $DayName = substr((localtime()),0,3));


	return $DayName;
}

# -------------------------------------------------------------------------------
# Name   : getDateStrFilename
# Purpose: Returns Date String for the filename
# Return : $dateStr
# -------------------------------------------------------------------------------
sub getDateStrFilename {

	my $dateStr = `$DATE '+%Y%m%d%H%M%S'`;

	chomp $dateStr;

	return $dateStr;
}

# -------------------------------------------------------------------------------
# Name   : getMonth
# Purpose: Returns month with different format. 
#          Ex) 1 -> Jan or Jan -> 1
# Parameter : Either month number of month name
# Return : month
# -------------------------------------------------------------------------------
sub getMonth {
	my %months1 = ( 'Jan' => '01' , 'Feb' => '02' , 'Mar' => '03' , 'Apr' => '04' , 'May' => '05' , 'Jun' => '06' ,
		        'Jul' => '07' , 'Aug' => '08' , 'Sep' => '09' , 'Oct' => '10' , 'Nov' => '11' , 'Dec' => '12' );
	my %months2 = ( '01' => 'Jan' , '02' => 'Feb' , '03' => 'Mar' , '04' => 'Apr' , '05' => 'May' , '06' => 'Jun' ,
		        '07' => 'Jul' , '08' => 'Aug' , '09' => 'Sep' , '10' => 'Oct' , '11' => 'Nov' , '12' => 'Dec' );

	if ( $_[0] =~ /\d+/ ) {
		return $months2{$_[0]};
	} else {
		return $months1{$_[0]};
	}

}

# -------------------------------------------------------------------------------
# Name   : getDay
# Purpose: Returns day with different format.
#          Ex) 1 -> 01
# Parameter : Day
# Return : 0 Padded day
# -------------------------------------------------------------------------------
sub getDay {
        my $today = $_[0];

        my %days = ( '1' => '01', '2' => '02' , '3' => '03' , '4' => '04' , '5' => '05',
                     '6' => '06', '7' => '07' , '8' => '08' , '9' => '09' );

        if ( $today =~ /^\d$/ ) {
                $day = $days{ $today }
        } else {
                return $today;
        }
}


# -------------------------------------------------------------------------------
# Name   : getFileContents
# Purpose: get the Contents of the file and return it as a string
# Return : $String
# -------------------------------------------------------------------------------
sub getFileContents {
        my $Filename = $_[0];
	my $Contents = '';

        open ( FILE , $Filename ) or die "Cannot open the file $Filename.\n";

        $Contents = join( '' , <FILE> );

        close FILE;

        return $Contents;
}


# -------------------------------------------------------------------------------
# Name   : setFileContents
# Purpose: write the Contents of the file and return it as a string
# Return : $String
# -------------------------------------------------------------------------------
sub setFileContents {
        my $Filename = $_[0];
        my $Contents = $_[1];

        open ( FILE , ">$Filename" ) or die "Cannot open the file $Filename.\n";

        print FILE "$Contents";

        close FILE;

}


sub isMonitor {
    my $dbname = shift;
    my $statusFile = "/tmp/.dbmonctl";
    my @current_db_status = split("\n", Util::UTIL::getFileContents($statusFile));

    foreach my $line ( @current_db_status ) {
        @_ = split(':',$line);
        if ( $_[0] eq "$dbname" ) {
            if ( $line =~ /Yes/ ) {
                return "Yes";
            } else {
                return "No";
            }
        }
    } 
    # if database not found in @currenex_db_status array then it's default(yes).
    return "Yes";          
}


1;










