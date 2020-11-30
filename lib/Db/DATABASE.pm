#!/usr/bin/perl -w 
#
# jyoon         2012/10/10	Use getParameter function to get any database parameter
# jyoon         2010/03/19      Merge several individual database call function into common one.
# jyoon		2009/02/03	Remove use of sysdba user and use dba user with MD5 Encryption.
# jyoon		2008/12/02	Package moved under Db::DATABASE
# jyoon		2008/11/21	Modified to user parameter file
# jyoon		2008/03/25	Package Created
#
use strict;
package Db::DATABASE;

use Db::CONFIG;
use Util::UTIL;

my $ECHO = '/bin/echo';

my %STATUS = ( 'FAILED',  0, 'SUCCEED', 1 );



sub new {
	my $class = shift;

	my $obj = { _database => $_[0], 
		    _status  => undef,
                    _message => undef
		  };

	bless $obj, $class;

	return $obj;
}

# -------------------------------------------------------------------
# Name       : getListenerStatus
# Parameters : $self
# Return     : ( $error_code, $error_mesg )
# -------------------------------------------------------------------
sub getListenerStatus {

	my ( $self ) = shift;

	my $config = new Db::CONFIG( $self->{_database} );

	$config->setDbEnv();

	$self->{_message} = `$ENV{ORACLE_HOME}/bin/lsnrctl status`;


	if ( $self->{_message} =~ /TNS-12541|TNS-12560|TNS-00511/ ) {

		$self->{_status} = $STATUS{'FAILED'};

	} else {

		$self->{_status} = $STATUS{'SUCCEED'};

	}

	return ( $self->{_status} , $self->{_message} );
}



# -------------------------------------------------------------------------------
# Name       : runSQL_by_internal 
# Parameters : $self, $sql_file , @params
# Return     : ( $error_code, $error_mesg )
# Purpose    : Consolidated all queries that needs to be run as internal user
# -------------------------------------------------------------------------------
sub runSQL_by_internal {
    my ( $self, $sql_file, @params ) = @_;

    my $list_parameters = join (' ', @params);
    my $config = new Db::CONFIG( $self->{_database} );

    #return `. $ENV{HOME}/.bash_profile; $ENV{ORACLE_HOME}/bin/sqlplus \-s \"/ as sysdba\" \@$sql_file $list_parameters`;
    return `$ENV{ORACLE_HOME}/bin/sqlplus \-s \"/ as sysdba\" \@$sql_file $list_parameters`;
}

# -------------------------------------------------------------------------------
# Name       : runSQL1
# Parameters : $self, $sql_file , $check_str , @params
# Return     : ( $error_code, $error_mesg )
# -------------------------------------------------------------------------------
sub runSQL1 {
    my ( $self , $sys_user, $sql_file , $check_str , @params ) = @_;

    my $list_parameters = join ( ' ', @params );
    my $host_name = `/bin/hostname`;
    chomp($host_name);

    # 2017/01/01 - Changed to Simple Connection for multitenant database
    $self->{_message} = `$ENV{ORACLE_HOME}/bin/sqlplus $sys_user\@$host_name/$self->{_database} \@$sql_file $list_parameters`;
    
    return ( $self->{_message} =~ /$check_str/ )?  ( $STATUS{'SUCCEED'} , $self->{_message} )
                                                 : ( $STATUS{'FAILED'}  , $self->{_message} );

}


# -------------------------------------------------------------------------------
# Name       : runSQL2
# Parameters : $self, $sql_file , @params
# Return     : ( $error_code, $error_mesg )
# -------------------------------------------------------------------------------
sub runSQL2 { 
    my ( $self , $sys_user, $sql_file , @params ) = @_;

    my $list_parameters = join ( ' ', @params );

    my $host_name = `/bin/hostname`;
    chomp($host_name);

    return `$ENV{ORACLE_HOME}/bin/sqlplus -s $sys_user\@$host_name/$self->{_database} \@$sql_file $list_parameters`;

}



# -------------------------------------------------------------------------------
# Name        : getParameter 
# Parameters  : $self, $parameter
# Return      : parameter value
# -------------------------------------------------------------------------------
sub getParameter {
    my ( $self , $parameter ) = @_;

    my $config = new Db::CONFIG ( $self->{_database} );


    $_ = $self->runSQL2($config->getSysUser(), "$ENV{ORACLE_BASE}/admin/DBA/lib/Db/sql/parameter.sql", $parameter ); 
    $_ =~ s/\n//g;
    
    return $_;
}


# -------------------------------------------------------------------------------
# Name   : GetAlertLog
# Purpose: To get the contents of alert.log of specific day.
# Prameters : $logfile , $date(yyyy/mm/dd)
# Return : Log
# -------------------------------------------------------------------------------
sub GetAlertLog {
        my ( $self, $dateStr , $logfile ) = ( @_ );
        my ( $year, $mon , $day ) = ( '','','' );
        my $IsDay = 0;


        my $config = new Db::CONFIG ( $self->{_database} );

        # 2012/10/10 : jyoon - start using getParameter function
        #$logfile = $config->getAlertFile();
        # 2015/07/29 : jyoon - removed since it doesn't need. 
        #$logfile = $self->getParameter('background_dump_dest') . '/alert_' . $config->getOraSid() . '.log';


        open ( ALERT_LOG , $logfile ) or die "$logfile can not be opened.";

        while ( <ALERT_LOG> ) {
                if ( /^\S+\s+(\S+)\s+(\d+)\s+\d+:\d+:\d+\s+(\d+)/ ) {

                        # Convert yyyy/m/d to yyyy/mm/dd format in case.
                        ( $mon , $day , $year ) = ( Util::UTIL::getMonth($1) , Util::UTIL::getDay($2) , $3 );


                        # print "$year/$mon/$day\n";
                        if ( $dateStr eq "$year/$mon/$day" ) {
                                $IsDay = 1;
                        }  else {
                                $IsDay = 0;
                        }
                }

                if ( $IsDay ) {
                        chomp;
                        if ( /ORA-/ ) {
                                #$self->{_message} .= "<FONT COLOR=FF0000 SIZE=2>" . $_ . "</FONT><br>";
                                $self->{_message} .= "<FONT COLOR=FF0000>" . $_ . "</FONT><br>";
                        } else {
                                #$self->{_message} .= $_ . "<br>" ;
                                $self->{_message} .= $_ . "<br>" ;
                        }
                }

        }

        close ALERT_LOG;

        return $self->{_message};
}

1;

