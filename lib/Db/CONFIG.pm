#!/usr/bin/perl -w
#
# jyoon		2009/02/03	Add MD5 Encription to encrypt password in the ini file.
# jyoon         2008/12/30      Bug fixed
#                               Function may return wrong database lists due to the absent of filtering.
# jyoon		2008/12/02	Package moved under Db::CONFIG
# jyoon		2008/11/20	Started object feature
# jyoon         2008/11/05      Package Created
#

use strict;

use Config::INI::Simple;
use Digest::MD5;

use lib '/home/app/crs/product/11g/perl/lib/site_perl/5.8.3/x86_64-linux-thread-multi';

package Db::CONFIG;


my $ini = "/home/app/oracle/admin/DBA/config/database.ini";


sub new {

	my $class = shift;

	my $obj = { _database      => $_[0] ,
		    _oracle_sid    => undef ,
		    _is_standby    => undef ,
                    _is_asm        => undef ,
                    _db_type       => undef ,
                    _oracle_base   => undef ,
                    _oracle_home   => undef ,

		    _rman_backup_type => undef ,
		    _run_export       => undef ,

		   };

	bless $obj , $class;

	if ( !defined $obj->{ _database }  ) {

		$obj->setDefaultDb();
	} 

	$obj->init_val();
        $obj->setDbEnv();

	return $obj;
	
}


sub init_val {
	my ( $self ) = shift;
	my $database = $self->{_database};


        my $config = new Config::INI::Simple;

        $config->read("$ini");

        $self->{ _oracle_base }   = $config->{$database}->{oracle_base};
        $self->{ _oracle_home }   = $config->{$database}->{oracle_home};
        $self->{ _oracle_sid }    = $config->{$database}->{oracle_sid};
	$self->{ _is_standby }    = $config->{$database}->{is_standby};
	$self->{ _is_asm }        = $config->{$database}->{is_asm};
        $self->{ _db_type }       = $config->{$database}->{db_type};
	
	$self->{ _encrypt_seed }  = $config->{$database}->{encrypt_seed};
        $self->{ _sys_user }      = $config->{$database}->{sys_user};
        $self->{ _system_user }   = $config->{$database}->{system_user};

	$self->{ _rman_backup_type } = $config->{$database}->{rman_backup_type};
	$self->{ _run_export}        = $config->{$database}->{run_export};

}

sub setDbEnv {

	my ( $self ) = shift;

	$ENV{ORACLE_SID}       = $self->{ _oracle_sid };
	$ENV{ORACLE_BASE}      = $self->{ _oracle_base };
	$ENV{ORACLE_HOME}      = $self->{ _oracle_home };
        $ENV{PATH}            .= "$ENV{ORACLE_HOME}/bin";
        $ENV{LD_LIBRARY_PATH} .= "$ENV{ORACLE_HOME}/lib";
        $ENV{NLS_DATE_FORMAT}  = 'MON-DD-YYYY HH24:MI:SS';

}

sub isExport {
        my ( $self ) = shift;

        return $self->{ _run_export};
}

sub getRmanBackupType {

	my ( $self ) = shift;

	return $self->{ _rman_backup_type };
}


sub getOraHome {

	my ( $self ) = shift;

	return $self->{ _oracle_home };

}

sub getOraBase {

        my ( $self ) = shift;

        return $self->{ _oracle_base };

}

sub getOraSid {

	my ( $self ) = shift;

	return $self->{ _oracle_sid };

}

sub isStandby {
	my ( $self ) = shift;
	
	return $self->{ _is_standby };
}

sub isAsm {
	my ( $self ) = shift;

	return $self->{ _is_asm };
}

sub getDbType {
	my ( $self ) = shift;

        return $self->{ _db_type };
}

sub getDbName {
	my ( $self ) = shift;

	return $self->{ _database };
}

sub getSysUser {

	my ( $self ) = shift;
	
	my $user = $self->Encode( $self->{ _sys_user } );

	return $user;

}

sub getSystemUser {

	my ( $self ) = shift;

        my $user = $self->Encode( $self->{ _system_user } );

	return $user;

}

sub setDefaultDb {
	my ( $self ) = shift;
	
        my $config = new Config::INI::Simple;

        $config->read("$ini");

	$self->{ _database } = $config->{default}->{database};
}


# -----------------------------------------------------------
# Static function and should be called Db::CONFIG::getDbList()
# Return database names in the array.
# -----------------------------------------------------------
sub getDbList {

        my $config = new Config::INI::Simple;

        $config->read("$ini");

        my @blocks = $config->blocks;
        my @databases = ();

        # Bug fixed on 2008/12/30
        # Function may return wrong database lists due to the absent of filtering.
        foreach my $block ( @blocks ) {
                if ( $block !~ /default|__file__|__eol__/ ) {
                        push @databases, $block;
                }
        }
        #pop @databases;
        #pop @databases;

        return @databases;
}


sub Encode {
	my ( $self , $token ) = @_;
	my $digest;

        my ( $un, $pw ) = split ( '/', $token );

	if ( $self->{ _encrypt_seed } == 0 ) {
		return "$un/$pw";
	}

	my $md5 = Digest::MD5->new;


	$md5->add( $pw );

	for ( my $i = 0; $i < $self->{ _encrypt_seed } ; $i++ ) {
		
		$digest = $md5->b64digest;
	
		$md5->add ( $digest );
	}
	
	return "$un/$digest";
}

1;



