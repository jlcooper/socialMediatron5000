use strict;

#
# Mock out the actual routines that call Elements as we don't want to
# call it in our testing
#

use DspaceAPI;

package DspaceAPI;

my %callResponse;
my $apiCalls = [];

sub pushResponse {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    $callResponse{$parameters->{url}} = {
        status => $parameters->{status},
        response => $parameters->{response},
    };
}


sub callAPI {
    my ($self, $apiUrl) = @_;

    my $objId = ident $self;

    push @{$apiCalls}, $apiUrl;

    my $response = $callResponse{$apiUrl};

    if (!$response) {
        croak "unknown URL called - $apiUrl";
    }

    return $response;
}


sub clearResponses {
    my ($self) = @_;

    %callResponse = ();
}

sub getApiCalls {
    my ($self) = @_;

    return $apiCalls;
}

sub clearApiCalls {
    my ($self) = @_;

    $apiCalls = [];
}



package DspaceAgent::Test;

use base 'Test::Class';

use DspaceAgent;
use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Perl6::Slurp;
use Clone qw(clone);
use URI::Escape;

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_8 $TEST_ERROR_CONFIGURATION_8

    $TEST_CONFIGURATION_8_WITH_BLACKLIST
    $TEST_CONFIGURATION_8_WITH_WHITELIST
    $TEST_CONFIGURATION_8_WITH_TYPES
    $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES

    $TEST_CONFIGURATION_8_INSIDE_HARVEST_PERIOD
);

use Data::TestDspaceAPI qw(
    $PUBLICATIONS_SINCE_1 $PUBLICATIONS_SINCE_TERMINATOR

    $SETS_1 $SETS_2 $SETS_3 $SETS_4

    $SET_SPEC_TO_NAME_MAPPING


    $PUBLICATION_1 $PUBLICATION_2 $PUBLICATION_3 $PUBLICATION_4
    $PUBLICATION_5 $PUBLICATION_6 $PUBLICATION_7
);

my $dspaceAPI;

my $database;
my $dspaceAgent;
my $originalConfigurationPublishedSince;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    # Reset our test configurations
    if ($originalConfigurationPublishedSince) {
        $TEST_CONFIGURATION_8->{publishedSince}=$originalConfigurationPublishedSince;
        $TEST_CONFIGURATION_8_WITH_BLACKLIST->{publishedSince}=$originalConfigurationPublishedSince;
        $TEST_CONFIGURATION_8_WITH_WHITELIST->{publishedSince}=$originalConfigurationPublishedSince;
        $TEST_CONFIGURATION_8_WITH_TYPES->{publishedSince}=$originalConfigurationPublishedSince;
        $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES->{publishedSince}=$originalConfigurationPublishedSince;
    } else {
        $originalConfigurationPublishedSince = $TEST_CONFIGURATION_8->{publishedSince};
    }

    $database->saveConfiguration($TEST_CONFIGURATION_8);
    $database->saveConfiguration($TEST_CONFIGURATION_8_WITH_BLACKLIST);
    $database->saveConfiguration($TEST_CONFIGURATION_8_WITH_WHITELIST);
    $database->saveConfiguration($TEST_CONFIGURATION_8_WITH_TYPES);
    $database->saveConfiguration($TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES);
    $database->saveConfiguration($TEST_CONFIGURATION_8_INSIDE_HARVEST_PERIOD);

    DspaceAPI->clearResponses();
    DspaceAPI->clearApiCalls();

    my $oaipmhUrl = $TEST_CONFIGURATION_8->{oaipmhBaseUrl};
    my $publishedSince = $TEST_CONFIGURATION_8->{publishedSince};

    DspaceAPI->pushResponse({
        url => "$oaipmhUrl?verb=ListSets",
        status => $SETS_1->{status},
        response => $SETS_1->{response}
    });
    
    DspaceAPI->pushResponse({
        url => "$oaipmhUrl?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
        status => $SETS_2->{status},
        response => $SETS_2->{response}
    });
    
    DspaceAPI->pushResponse({
        url => "$oaipmhUrl?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
        status => $SETS_3->{status},
        response => $SETS_3->{response}
    });
    
    DspaceAPI->pushResponse({
        url => "$oaipmhUrl?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",
        status => $SETS_4->{status},
        response => $SETS_4->{response}
    });

    DspaceAPI->pushResponse({
        url => "$oaipmhUrl?verb=ListRecords&metadataPrefix=oai_dc&from=" . uri_escape($publishedSince),
        status => $PUBLICATIONS_SINCE_1->{status},
        response => $PUBLICATIONS_SINCE_1->{response}
    });
 
    DspaceAPI->pushResponse({
        url => "$oaipmhUrl?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        status => $PUBLICATIONS_SINCE_TERMINATOR->{status},
        response => $PUBLICATIONS_SINCE_TERMINATOR->{response},
    });
}


sub _new : Test(3) {
    throws_ok {DspaceAgent->new()} qr/missing required parameters/;
    throws_ok {DspaceAgent->new({
        database => $database,
        configuration => $TEST_ERROR_CONFIGURATION_8,
    })} qr/missing required configuration settings/;

    my $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8,
    });

    isa_ok($dspaceAgent, 'DspaceAgent');
}


sub harvest : Test(5) {
    $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8,
    });

    my $originalPublishedSince = $TEST_CONFIGURATION_8->{publishedSince};
    my $oaipmhBaseUrl = $TEST_CONFIGURATION_8->{oaipmhBaseUrl};

    $dspaceAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_8->{_id});

    ok(time() - $configuration->{lastHarvested} < 10, 'We just harvested so the last harvested timestamp should be within the last 10 seconds.');

    my (undef, undef, undef, $day, $month, $year) = localtime(time() - (24 * 60 * 60));
    $month++;
    $year += 1900;

    my $expectedPublishedSinceDate = sprintf("%04d-%02d-%02d 00:00:00",$year ,$month, $day);
 
    is($configuration->{publishedSince}, $expectedPublishedSinceDate, 'Harvesting should update the configurations publishedSince property.');
 
    cmp_deeply(DspaceAPI->getApiCalls(),
        bag(
            "$oaipmhBaseUrl?verb=ListSets",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$oaipmhBaseUrl?verb=ListRecords&metadataPrefix=oai_dc&from=" . uri_escape($originalPublishedSince),
            "$oaipmhBaseUrl?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case harvest should call the correct OAIPMH URLs"
    );

    my $items = $database->getItems();
 
    foreach my $item (@{$items}) {
        delete $item->{_id};
        delete $item->{statuses};
        delete $item->{timestamps};
    }

    is(scalar @{$items}, 7, 'We should have 7 harvested items');

    cmp_deeply($items,
        bag(
            $PUBLICATION_1, $PUBLICATION_2, $PUBLICATION_3, $PUBLICATION_4,
            $PUBLICATION_5, $PUBLICATION_6, $PUBLICATION_7
        ),
        "After harvesting our database should contain the items"
    );
}

sub harvestWithBlackList : Test(4) {
    $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8_WITH_BLACKLIST,
    });

    my $originalPublishedSince = $TEST_CONFIGURATION_8_WITH_BLACKLIST->{publishedSince};
    my $oaipmhBaseUrl = $TEST_CONFIGURATION_8_WITH_BLACKLIST->{oaipmhBaseUrl};

    $dspaceAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_8_WITH_BLACKLIST->{_id});

    my (undef, undef, undef, $day, $month, $year) = localtime(time() - (24 * 60 * 60));
    $month++;
    $year += 1900;

    my $expectedPublishedSinceDate = sprintf("%04d-%02d-%02d 00:00:00",$year ,$month, $day);
 
    is($configuration->{publishedSince}, $expectedPublishedSinceDate, 'Harvesting should update the configurations publishedSince property.');
 
    cmp_deeply(DspaceAPI->getApiCalls(),
        bag(
            "$oaipmhBaseUrl?verb=ListSets",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$oaipmhBaseUrl?verb=ListRecords&metadataPrefix=oai_dc&from=" . uri_escape($originalPublishedSince),
            "$oaipmhBaseUrl?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case harvest should call the correct OAIPMH URLs"
    );

    my $items = $database->getItems();
 
    foreach my $item (@{$items}) {
        delete $item->{_id};
        delete $item->{statuses};
        delete $item->{timestamps};
    }

    is(scalar @{$items}, 5, 'We should have 5 harvested items');

    cmp_deeply($items,
        bag(
            $PUBLICATION_1, $PUBLICATION_2, $PUBLICATION_3, $PUBLICATION_4,
            $PUBLICATION_5
        ),
        "After harvesting our database should contain the items"
    );
}

sub harvestWithWhiteList : Test(4) {
    $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8_WITH_WHITELIST,
    });

    my $originalPublishedSince = $TEST_CONFIGURATION_8_WITH_WHITELIST->{publishedSince};
    my $oaipmhBaseUrl = $TEST_CONFIGURATION_8_WITH_WHITELIST->{oaipmhBaseUrl};

    $dspaceAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_8_WITH_WHITELIST->{_id});

    my (undef, undef, undef, $day, $month, $year) = localtime(time() - (24 * 60 * 60));
    $month++;
    $year += 1900;

    my $expectedPublishedSinceDate = sprintf("%04d-%02d-%02d 00:00:00",$year ,$month, $day);
 
    is($configuration->{publishedSince}, $expectedPublishedSinceDate, 'Harvesting should update the configurations publishedSince property.');
 
    cmp_deeply(DspaceAPI->getApiCalls(),
        bag(
            "$oaipmhBaseUrl?verb=ListSets",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$oaipmhBaseUrl?verb=ListRecords&metadataPrefix=oai_dc&from=" . uri_escape($originalPublishedSince),
            "$oaipmhBaseUrl?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case harvest should call the correct OAIPMH URLs"
    );

    my $items = $database->getItems();
 
    foreach my $item (@{$items}) {
        delete $item->{_id};
        delete $item->{statuses};
        delete $item->{timestamps};
    }

    is(scalar @{$items}, 3, 'We should have 3 harvested items');

    cmp_deeply($items,
        bag(
            $PUBLICATION_1, $PUBLICATION_2, $PUBLICATION_3
        ),
        "After harvesting our database should contain the items"
    );
}

sub harvestWithTypes : Test(4) {
    $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8_WITH_TYPES,
    });

    my $originalPublishedSince = $TEST_CONFIGURATION_8_WITH_TYPES->{publishedSince};
    my $oaipmhBaseUrl = $TEST_CONFIGURATION_8_WITH_TYPES->{oaipmhBaseUrl};

    $dspaceAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_8_WITH_TYPES->{_id});

    my (undef, undef, undef, $day, $month, $year) = localtime(time() - (24 * 60 * 60));
    $month++;
    $year += 1900;

    my $expectedPublishedSinceDate = sprintf("%04d-%02d-%02d 00:00:00",$year ,$month, $day);
 
    is($configuration->{publishedSince}, $expectedPublishedSinceDate, 'Harvesting should update the configurations publishedSince property.');
 
    cmp_deeply(DspaceAPI->getApiCalls(),
        bag(
            "$oaipmhBaseUrl?verb=ListSets",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$oaipmhBaseUrl?verb=ListRecords&metadataPrefix=oai_dc&from=" . uri_escape($originalPublishedSince),
            "$oaipmhBaseUrl?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case harvest should call the correct OAIPMH URLs"
    );

    my $items = $database->getItems();
 
    foreach my $item (@{$items}) {
        delete $item->{_id};
        delete $item->{statuses};
        delete $item->{timestamps};
    }

    is(scalar @{$items}, 5, 'We should have 5 harvested items');

    cmp_deeply($items,
        bag(
            $PUBLICATION_2, $PUBLICATION_4, $PUBLICATION_5, $PUBLICATION_6,
            $PUBLICATION_7,
        ),
        "After harvesting our database should contain the items"
    );
}

sub harvestWithBlackListAndTypes : Test(4) {
    $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES,
    });

    my $originalPublishedSince = $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES->{publishedSince};
    my $oaipmhBaseUrl = $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES->{oaipmhBaseUrl};

    $dspaceAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES->{_id});

    my (undef, undef, undef, $day, $month, $year) = localtime(time() - (24 * 60 * 60));
    $month++;
    $year += 1900;

    my $expectedPublishedSinceDate = sprintf("%04d-%02d-%02d 00:00:00",$year ,$month, $day);
 
    is($configuration->{publishedSince}, $expectedPublishedSinceDate, 'Harvesting should update the configurations publishedSince property.');
 
    cmp_deeply(DspaceAPI->getApiCalls(),
        bag(
            "$oaipmhBaseUrl?verb=ListSets",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$oaipmhBaseUrl?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$oaipmhBaseUrl?verb=ListRecords&metadataPrefix=oai_dc&from=" . uri_escape($originalPublishedSince),
            "$oaipmhBaseUrl?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case harvest should call the correct OAIPMH URLs"
    );

    my $items = $database->getItems();
 
    foreach my $item (@{$items}) {
        delete $item->{_id};
        delete $item->{statuses};
        delete $item->{timestamps};
    }

    is(scalar @{$items}, 3, 'We should have 3 harvested items');

    cmp_deeply($items,
        bag(
            $PUBLICATION_2, $PUBLICATION_4, $PUBLICATION_5
        ),
        "After harvesting our database should contain the items"
    );
}


sub dontHarvestTooOften : Test(1) {
    $dspaceAgent = DspaceAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_8_INSIDE_HARVEST_PERIOD,
    });

    $dspaceAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_8_INSIDE_HARVEST_PERIOD->{_id});

    ok(time() - $configuration->{lastHarvested} > 10, 'We should not have just harvested so the last harvested timestamp should not have been updated.');
}

1;
