#!/usr/bin/perl -w
# $Header: /home/app/oracle/admin/DBA/crontab/report/database_stat.pl,v 1.0  2007/01/22 jyoon Exp $
# 
# database_stat.pl
# 
# jyoon		2008/12/17 - Started OOP 
# jyoon		2007/01/22 - Created
#
# 1. Database statistics
#
use lib '/home/app/oracle/admin/DBA/lib';

use Util::UTIL;
use Db::CONFIG;

my $htmlStr = '';

$htmlStr = ArrangeReport();

print $htmlStr;

# -------------------------------------------------------------------------------
# Name   : ArrangeReport
# Purpose: This routine serialize the report of the databases on the server.
# Return : N/A
# -------------------------------------------------------------------------------
sub ArrangeReport {
	my @databases = Db::CONFIG::getDbList();
	my $html     = '';
	
	
	foreach my $dbname ( @databases ) {
		
		my $config = new Db::CONFIG( $dbname );
     
                if ( $config->isStandby() =~ /yes/i || $config->isAsm() =~ /yes/i ) {   # Do nothing 
                        next;                                                           # if it's Standby or ASM
                }

		$config->setDbEnv();

		$userInfo = $config->getSystemUser();

		$html .= GenReport( $userInfo );
	}

	return $html;
}

# -------------------------------------------------------------------------------
# Name   : GenReport 
# Purpose: Generating report the current database
# Return : html string
# -------------------------------------------------------------------------------
sub GenReport() {
	my $userInfo = $_[0];
        my $REPORT_DIR = "$ENV{ORACLE_BASE}/admin/DBA/crontab/scripts/report";

	my $template = "$REPORT_DIR/sql/snap\.sql";
	my $snapfile = "$REPORT_DIR/snap\.sql";
	my $html = '';
	
	open ( FILE , "$template" ) or die "Cannot open the file $template\n";
	open ( OUT , ">$snapfile" ) or die "Cannot open the file $snapfile\n";

	while ( <FILE> ) {
		s/start sql/start $REPORT_DIR\/sql/;
		print OUT $_;
	}
	close FILE;
	close OUT;

        $html = `$ENV{ORACLE_HOME}/bin/sqlplus \-s $userInfo \@$REPORT_DIR/snap.sql`; 
	
	return $html;
}




