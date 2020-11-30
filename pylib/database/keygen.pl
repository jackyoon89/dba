#!/usr/bin/perl -w 

use Digest::MD5;
use Getopt::Long;
    
use vars qw ( $seed_number $token $IsHelp );

main();

sub main {

	GetOptions ( 'seed_number=s' => \$seed_number , 'token=s' => \$token , 'help' => \$IsHelp );

	if ( defined $IsHelp || !defined $token ) {
		print "\nThis utility help to generate random key based on 64based encoding.\n";
		print "By default seed_number is 1.\n\n";
		print "example : genkey.pl --seed_number=number(1) --token=string\n";
                print "                    --help\n\n";

		exit;

	}

	if ( !defined $seed_number ) {
		$seed_number = 1; 
	}

	$token = Encode ( $token , $seed_number );

	print "$token\n";
}

sub Encode {
	my ($token, $counter ) = @_;

	# NoEncryption if $counter is 0.
	if ( $counter == 0 ) {
		return $token;
	}

	my $md5 = Digest::MD5->new;

	$md5->add( $token );

	for ( my $i = 0; $i < $counter ; $i++ ) {

		$digest = $md5->b64digest;

		$md5->add( $digest );
	}

	return $digest;
}
