use strict;

package Controller::Test;

use base 'Test::Class';

use Controller;
use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_1 $TEST_CONFIGURATION_2 $TEST_CONFIGURATION_3
    $TEST_CONFIGURATION_4 $TEST_CONFIGURATION_5 $TEST_CONFIGURATION_6
);

use Fake::Database;
use Data::Dumper;

my $controller;
my $database;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration($TEST_CONFIGURATION_1);
    $database->saveConfiguration($TEST_CONFIGURATION_2);
    $database->saveConfiguration($TEST_CONFIGURATION_3);
    $database->saveConfiguration($TEST_CONFIGURATION_4);
    $database->saveConfiguration($TEST_CONFIGURATION_5);
    $database->saveConfiguration($TEST_CONFIGURATION_6);

    $controller = Controller->new({
        database => $database,
    });
}


sub _new : Test(2) {
    throws_ok {Controller->new()} qr/missing required parameters/;
    isa_ok($controller, 'Controller');
}


sub getHarvestingAgents : Test(3) {
    my $harvestingAgents = $controller->getHarvestingAgents();

    ok(scalar @{$harvestingAgents} == 2, 'getHarvestingAgents should return two entries');
    isa_ok($harvestingAgents->[0], 'Fake::LupinAgent');
    isa_ok($harvestingAgents->[1], 'Fake::LupinAgent');
}

sub getPublishingAgents : Test(3) {
    my $publishingAgents = $controller->getPublishingAgents();

    ok(scalar @{$publishingAgents} == 2, 'getPublishingAgents should return two entries');
    isa_ok($publishingAgents->[0], 'Fake::TwitterAgent');
    isa_ok($publishingAgents->[1], 'Fake::TwitterAgent');
}

1;
