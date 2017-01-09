use strict;

#
# Mock out the actual routines that call Elements as we don't want to
# call it in our testing
#

use RSSAPI;

package RSSAPI;

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



package RSSAgent::Test;

use base 'Test::Class';

use RSSAgent;
use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Perl6::Slurp;
use Clone qw(clone);
use URI::Escape;

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_9
    $TEST_CONFIGURATION_9_INSIDE_HARVEST_PERIOD
    $TEST_ERROR_CONFIGURATION_9 
);

use Data::TestRSSAPI qw(
    $RSS_FEED_1

    $ITEM_1  $ITEM_2  $ITEM_3  $ITEM_4  $ITEM_5
    $ITEM_6  $ITEM_7  $ITEM_8  $ITEM_9  $ITEM_10
    $ITEM_11 $ITEM_12 $ITEM_13 $ITEM_14 $ITEM_15
    $ITEM_16

    $HARVESTED_ITEM_1  $HARVESTED_ITEM_2  $HARVESTED_ITEM_3  $HARVESTED_ITEM_4
    $HARVESTED_ITEM_5  $HARVESTED_ITEM_6  $HARVESTED_ITEM_7  $HARVESTED_ITEM_8
    $HARVESTED_ITEM_9  $HARVESTED_ITEM_10 $HARVESTED_ITEM_11 $HARVESTED_ITEM_12
    $HARVESTED_ITEM_13 $HARVESTED_ITEM_14 $HARVESTED_ITEM_15 $HARVESTED_ITEM_16

);

my $rssAPI;

my $database;
my $rssAgent;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration($TEST_CONFIGURATION_9);
    $database->saveConfiguration($TEST_CONFIGURATION_9_INSIDE_HARVEST_PERIOD);

    RSSAPI->clearResponses();
    RSSAPI->clearApiCalls();

    RSSAPI->pushResponse({
        url => $RSS_FEED_1->{url},
        status => $RSS_FEED_1->{status},
        response => $RSS_FEED_1->{response},
    });

    $rssAgent = RSSAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_9,
    });
}


sub _new : Test(3) {
    throws_ok {RSSAgent->new()} qr/missing required parameters/;
    throws_ok {RSSAgent->new({
        database => $database,
        configuration => $TEST_ERROR_CONFIGURATION_9,
    })} qr/missing required configuration settings/;

    isa_ok($rssAgent, 'RSSAgent');
}


sub harvest : Test(5) {
    $rssAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_9->{_id});

    ok(time() - $configuration->{lastHarvested} < 10, 'We just harvested so the last harvested timestamp should be within the last 10 seconds.');

    cmp_deeply(RSSAPI->getApiCalls(),
        bag(
            $TEST_CONFIGURATION_9->{rssUrl}
        ),
        "In this case harvest should call the correct URL"
    );

    my $items = $database->getItems();

    my $correctType = 1;
 
    foreach my $item (@{$items}) {
        delete $item->{_id};
    }

    is(scalar @{$items}, 16, 'We should have 16 harvested items');

    ok($correctType, 'All items should hav a type of Feed Entry');

#    use Data::Dumper;
#    warn Dumper($items);

    cmp_deeply($items,
        bag(
            $HARVESTED_ITEM_1, $HARVESTED_ITEM_2,  $HARVESTED_ITEM_3, $HARVESTED_ITEM_4,
            $HARVESTED_ITEM_5, $HARVESTED_ITEM_6, $HARVESTED_ITEM_7, $HARVESTED_ITEM_8,
            $HARVESTED_ITEM_9, $HARVESTED_ITEM_10, $HARVESTED_ITEM_11, $HARVESTED_ITEM_12,
            $HARVESTED_ITEM_13, $HARVESTED_ITEM_14, $HARVESTED_ITEM_15, $HARVESTED_ITEM_16,
        ),
        "After harvesting our database should contain the items"
    );
}

sub dontHarvestTooOften : Test(1) {
    my $rssAgent = RSSAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_9_INSIDE_HARVEST_PERIOD,
    });
   
    $rssAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_9_INSIDE_HARVEST_PERIOD->{_id});

    ok(time() - $configuration->{lastHarvested} > 10, 'We should not have just harvested so the last harvested timestamp should not have changed.');
}

1;
