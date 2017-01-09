use strict;


package HarvestingAgent::Test;

use base 'Test::Class';

use HarvestingAgent;

use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Data::Dumper;
use Clone qw(clone);

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_10 $TEST_CONFIGURATION_11
);

my $database;
my $harvestingAgent;


sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration(clone ($TEST_CONFIGURATION_10));
    $database->saveConfiguration(clone ($TEST_CONFIGURATION_11));

    $harvestingAgent = HarvestingAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_10),
    });
}


sub _new : Test(2) {
    throws_ok {HarvestingAgent->new()} qr/missing required parameters/;
    
    isa_ok($harvestingAgent, 'HarvestingAgent');
}


sub readyToHarvest : Test(2) {
    my $agentReadyToHarvest = HarvestingAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_10),
    });

    ok($agentReadyToHarvest->readyToHarvest(), "An agent that last harvested longer than it's time between harvests should be ready to harvest");

    my $agentNotReadyToHarvest = HarvestingAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_11),
    });

    ok(!$agentNotReadyToHarvest->readyToHarvest(), "An agent that last harvested sooner than it's time between harvests should NOT be ready to harvest");

}


sub finishedHarvesting : Test(1) {
    $harvestingAgent->finishedHarvesting();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_10->{_id});
    my $lastHarvested = $configuration->{lastHarvested};

    ok((time - $lastHarvested) < 10, 'When harvesting has finished the lastHarvested timestamp should be updated');
}

1;
