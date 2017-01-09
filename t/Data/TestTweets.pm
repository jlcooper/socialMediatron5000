use strict;
use warnings;

package Data::TestTweets;

use base 'Exporter';

use MongoDB::OID;
use Readonly;
use DateTime;
use Test::Deep;
use Clone qw(clone);

our @EXPORT_OK = qw(
    $TEST_TWEET_1 $TEST_TWEET_2 $TEST_TWEET_3
    $TEST_TWEET_4
    $COMPARE_TWEET_1 $COMPARE_TWEET_2 $COMPARE_TWEET_3 $COMPARE_TWEET_4
);

Readonly our $TEST_TWEET_1 => {
    _id => MongoDB::OID->new(),
    tweet => 'Test Tweet 1',
    agent => 'Agent1',
    timestamp => DateTime->from_epoch( epoch => 1447843000),
};

Readonly our $COMPARE_TWEET_1 => {
    _id => $TEST_TWEET_1->{_id},
    tweet => 'Test Tweet 1',
    agent => 'Agent1',
    timestamp => ignore(),
};

Readonly our $TEST_TWEET_2 => {
    _id => MongoDB::OID->new(),
    tweet => 'Test Tweet 2',
    agent => 'Agent1',
    timestamp => DateTime->from_epoch( epoch => 1447844000 ),
};

Readonly our $COMPARE_TWEET_2 => {
    _id => $TEST_TWEET_2->{_id},
    tweet => 'Test Tweet 2',
    agent => 'Agent1',
    timestamp => ignore(),
};


Readonly our $TEST_TWEET_3 => {
    _id => MongoDB::OID->new(),
    tweet => 'Test Tweet 3',
    agent => 'Agent2',
    timestamp => DateTime->from_epoch( epoch => 1447845000 ),
};

Readonly our $COMPARE_TWEET_3 => {
    _id => $TEST_TWEET_3->{_id},
    tweet => 'Test Tweet 3',
    agent => 'Agent2',
    timestamp => ignore(),
};

Readonly our $TEST_TWEET_4 => {
    _id => MongoDB::OID->new(),
    tweet => 'Test Tweet 4',
    agent => 'Agent2',
    timestamp => DateTime->from_epoch( epoch => 1447846000 ),
};

Readonly our $COMPARE_TWEET_4 => {
    _id => $TEST_TWEET_4->{_id},
    tweet => 'Test Tweet 4',
    agent => 'Agent2',
    timestamp => ignore(),
};


1;
