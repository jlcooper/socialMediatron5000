#!/usr/bin/perl

use strict;
use warnings;

package Settings;

use base 'Exporter';

use Readonly;

our @EXPORT_OK = qw(
    %FACEBOOK_SETTINGS

    $DATABASE_HOST $DATABASE_PORT $DATABASE_NAME

    $CONSUMER_KEY $CONSUMER_SECRET

    $DSPACE_IDENTIFIER_MATCH

    $TEST_DATABASE_HOST $TEST_DATABASE_PORT $TEST_DATABASE_NAME
);

# This is the Facebook settings for the app, to use the facebook publishing agent you'll
# need to register your app with Facebook.
Readonly our %FACEBOOK_SETTINGS => (
    appId => '',
    secret => '',
    namespace => '',
);

# This is the Hostname, Port and Database name for your MongoDB instance
Readonly our $DATABASE_HOST => '';
Readonly our $DATABASE_PORT => ;
Readonly our $DATABASE_NAME => '';

# This is the settings for the Twitter publishing agent.  You'll get these when you 
# register your app with Twitter on https://apps.twitter.com/
Readonly our $CONSUMER_KEY => "";
Readonly our $CONSUMER_SECRET => "";

# This is the regular expresion used to identify an identifier for any DSpace agents being harvested
Readonly our $DSPACE_IDENTIFIER_MATCH => qr/^https?:\/\/hdl.handle.net\//i;

# This is the test MongoDB database used by the intergration tests
Readonly our $TEST_DATABASE_HOST => '';
Readonly our $TEST_DATABASE_PORT => ;
Readonly our $TEST_DATABASE_NAME => '';

1;
