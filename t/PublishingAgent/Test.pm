use strict;


package PublishingAgent::Test;

use base 'Test::Class';

use PublishingAgent;

use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Data::Dumper;
use Clone qw(clone);

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_4
    $TEST_CONFIGURATION_4_WITHOUT_ICYMI
    $TEST_CONFIGURATION_4_WITH_SOURCE
    $TEST_CONFIGURATION_4_WITH_SET
);

use Data::TestItems qw(
    $TEST_ITEM_1 $TEST_ITEM_2 $TEST_ITEM_3 $TEST_ITEM_4 $TEST_ITEM_5 $TEST_ITEM_6 $TEST_ITEM_7
);

my $database;
my $publishingAgent;


sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration(clone ($TEST_CONFIGURATION_4));
    $database->saveConfiguration(clone ($TEST_CONFIGURATION_4_WITH_SOURCE));

    $publishingAgent = PublishingAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_4),
    });
}


sub _new : Test(2) {
    throws_ok {PublishingAgent->new()} qr/missing required parameters/;
    
    isa_ok($publishingAgent, 'PublishingAgent');
}


sub validItemType : Test(4) {
    my $item1 = {
        type => ['dataset'],
    };
    my $item2 = {
        type => ['dataset', 'publication'],
    };
    my $item3 = {
        type => ['publication', 'dataset'],
    };
    my $item4 = {
        type => ['publication'],
    };

    ok($publishingAgent->validItemType($item1), 'an item with just a type of dataset should be valid');
    ok($publishingAgent->validItemType($item2), 'an item with a type of dataset and publication should be valid');
    ok($publishingAgent->validItemType($item3), 'an item with a type of publication and dataset should be valid');
    ok(!$publishingAgent->validItemType($item4), 'an item with just a type of publication should not be valid');    
}

sub validItemSource : Test(6) {
    my $item1 = {
        source => 'http://www.lboro.ac.uk/',
    };
    my $item2 = {
        source => 'http://www.google.com/',
    };
    my $item3 = {
    };

    ok($publishingAgent->validItemSource($item1), 'Sources should not matter when no source has been configured for agent');
    ok($publishingAgent->validItemSource($item2), 'Sources should not matter when no source has been configured for agent');
    ok($publishingAgent->validItemSource($item3), 'Sources should not matter when no source has been configured for agent');

    my $publishingAgentWithSource = PublishingAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_4_WITH_SOURCE),
    });

    ok($publishingAgentWithSource->validItemSource($item1), 'an item with just a source of http://www.lboro.ac.uk/ should be valid');
    ok(!$publishingAgentWithSource->validItemSource($item2), 'an item with just a source of http://www.google.com/ should not be valid');
    ok(!$publishingAgentWithSource->validItemSource($item3), 'an item without a source should not be valid');
}

sub validSets : Test(10) {
    my $item1 = {
        sets => [
            { "name" => "Big set", "id" => "com_2134_1" },
            { "name" => "Small set", "id" => "col_2134_2" },
            { "name" => "Tiny set", "id" => "col_2134_3"},
        ],
    };
    my $item2 = {
        sets => [
            { "name" => "Big set", "id" => "com_2134_1" },
        ],
    };
    my $item3 = {
        sets => [
            { "name" => "Small set", "id" => "col_2134_2" },
        ],
    };
    my $item4 = {
        sets => [
            { "name" => "Tiny set", "id" => "col_2134_3"},
        ],
    };
    my $item5 = {
    };

    ok($publishingAgent->validItemSet($item1), 'Sets should not matter when no set has been configured for agent');
    ok($publishingAgent->validItemSet($item2), 'Sets should not matter when no set has been configured for agent');
    ok($publishingAgent->validItemSet($item3), 'Sets should not matter when no set has been configured for agent');
    ok($publishingAgent->validItemSet($item4), 'Sets should not matter when no set has been configured for agent');
    ok($publishingAgent->validItemSet($item5), 'Sets should not matter when no set has been configured for agent');

    my $publishingAgentWithSet = PublishingAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_4_WITH_SET),
    });

    ok($publishingAgentWithSet->validItemSet($item1), 'an item with a set of Big set and Small set should be valid');
    ok($publishingAgentWithSet->validItemSet($item2), 'an item with just a set of Big set should be valid');
    ok($publishingAgentWithSet->validItemSet($item3), 'an item with just a set of Small set should be valid');
    ok(!$publishingAgentWithSet->validItemSet($item4), 'an item with just a set of Tine set should not be valid');
    ok(!$publishingAgentWithSet->validItemSet($item5), 'an item without a set should not be valid');
}

1;
