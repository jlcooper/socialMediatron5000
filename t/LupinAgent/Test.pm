use strict;

package LupinAgent::Test;

use base 'Test::Class';

use LupinAgent;
use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;

use Fake::Database;

use Data::TestConfigurations qw($TEST_CONFIGURATION_1);

my $database;
my $lupinAgent;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    $lupinAgent = LupinAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_1,
    });
}


sub _new : Test(2) {
    throws_ok {LupinAgent->new()} qr/missing required parameters/;

    my $lupinAgent = LupinAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_1,
    });

    isa_ok($lupinAgent, 'LupinAgent');
}

sub harvest : Test(1) {
    $lupinAgent->harvest();
}

1;
