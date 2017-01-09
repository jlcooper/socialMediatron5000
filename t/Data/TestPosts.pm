use strict;
use warnings;

package Data::TestPosts;

use base 'Exporter';

use MongoDB::OID;
use Readonly;
use DateTime;
use Test::Deep;
use Clone qw(clone);

our @EXPORT_OK = qw(
    $TEST_POST_1 $TEST_POST_2 $TEST_POST_3
    $TEST_POST_4
    $COMPARE_POST_1 $COMPARE_POST_2 $COMPARE_POST_3 $COMPARE_POST_4
);

Readonly our $TEST_POST_1 => {
    _id => MongoDB::OID->new(),
    post => {
        link => 'http://test.post.1/',
        message => 'Test Post 1',
    },
    agent => 'Agent1',
    timestamp => DateTime->from_epoch( epoch => 1447843000),
};

Readonly our $COMPARE_POST_1 => {
    _id => $TEST_POST_1->{_id},
    post => {
        link => 'http://test.post.1/',
        message => 'Test Post 1',
    },
    agent => 'Agent1',
    timestamp => ignore(),
};

Readonly our $TEST_POST_2 => {
    _id => MongoDB::OID->new(),
    post => {
        link => 'http://test.post.2/',
        message => 'Test Post 2',
    },
    agent => 'Agent1',
    timestamp => DateTime->from_epoch( epoch => 1447844000 ),
};

Readonly our $COMPARE_POST_2 => {
    _id => $TEST_POST_2->{_id},
    post => {
        link => 'http://test.post.2/',
        message => 'Test Post 2',
    },
    agent => 'Agent1',
    timestamp => ignore(),
};


Readonly our $TEST_POST_3 => {
    _id => MongoDB::OID->new(),
    post => {
        link => 'http://test.post.3/',
        message => 'Test Post 3',
    },
    agent => 'Agent2',
    timestamp => DateTime->from_epoch( epoch => 1447845000 ),
};

Readonly our $COMPARE_POST_3 => {
    _id => $TEST_POST_3->{_id},
    post => {
        link => 'http://test.post.3/',
        message => 'Test Post 3',
    },
    agent => 'Agent2',
    timestamp => ignore(),
};

Readonly our $TEST_POST_4 => {
    _id => MongoDB::OID->new(),
    post => {
        link => 'http://test.post.4/',
        message => 'Test Post 4',
    },
    agent => 'Agent2',
    timestamp => DateTime->from_epoch( epoch => 1447846000 ),
};

Readonly our $COMPARE_POST_4 => {
    _id => $TEST_POST_4->{_id},
    post => {
        link => 'http://test.post.4/',
        message => 'Test Post 4',
    },
    agent => 'Agent2',
    timestamp => ignore(),
};


1;
