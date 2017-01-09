#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/projects/rdmTwitterBot/trunk/lib';

use Settings qw(
    $CONSUMER_KEY $CONSUMER_SECRET
);

use Net::Twitter;

my $nt = Net::Twitter->new(
    traits          => ['API::RESTv1_1', 'OAuth'],
    consumer_key    => $CONSUMER_KEY,
    consumer_secret => $CONSUMER_SECRET,
);

# The client is not yet authorized: Do it now
print "Authorize this app at ", $nt->get_authorization_url, " and enter the PIN#\n";

my $pin = <STDIN>; # wait for input
chomp $pin;

my($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);

print <<EODETAILS;
access_token:        $access_token
access_token_secret: $access_token_secret
user_id:             $user_id
screen_name:         $screen_name
EODETAILS

