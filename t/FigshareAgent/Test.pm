use strict;

#
# Mock out the actual routines that call Elements as we don't want to
# call it in our testing
#

use FigshareAPI;

package FigshareAPI;

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
        croak "unknown URL called";
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
    $apiCalls = [];
}


package FigshareAgent::Test;

use base 'Test::Class';

use FigshareAgent;
use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Perl6::Slurp;
use Clone;

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_7 $TEST_ERROR_CONFIGURATION_7

    $TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD
);

use Data::TestFigshareAPI qw(
    $PUBLICATIONS_SINCE_1 $PUBLICATIONS_SINCE_TERMINATOR
    $PUBLICATION_1 $PUBLICATION_2 $PUBLICATION_3 $PUBLICATION_4
    $PUBLICATION_5 $PUBLICATION_6 $PUBLICATION_7 $PUBLICATION_8
    $HARVESTED_ITEM_1 $HARVESTED_ITEM_2 $HARVESTED_ITEM_3 $HARVESTED_ITEM_4
    $HARVESTED_ITEM_5 $HARVESTED_ITEM_6 $HARVESTED_ITEM_7 $HARVESTED_ITEM_8
    @ARTICLE_IDS
);

Readonly my $PUBLISHED_SINCE => '2015-11-13';

my $database;
my $figshareAgent;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration($TEST_CONFIGURATION_7);
    $database->saveConfiguration($TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD);

    $figshareAgent = FigshareAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_7,
    });

    FigshareAPI->clearApiCalls();
}


sub _new : Test(3) {
    throws_ok {FigshareAgent->new()} qr/missing required parameters/;
    throws_ok {FigshareAgent->new({
        database => $database,
        configuration => $TEST_ERROR_CONFIGURATION_7,
    })} qr/missing required configuration settings/;

    my $figshareAgent = FigshareAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_7,
    });

    isa_ok($figshareAgent, 'FigshareAgent');
}

sub harvest : Test(4) {

    my $originalPublishedSince = $TEST_CONFIGURATION_7->{publishedSince};

    FigshareAPI->pushResponse({
        url => "$TEST_CONFIGURATION_7->{apiUrl}/articles?institution=$TEST_CONFIGURATION_7->{institutionId}&published_since=$TEST_CONFIGURATION_7->{publishedSince}&page=1",
        status => $PUBLICATIONS_SINCE_1->{status},
        response => $PUBLICATIONS_SINCE_1->{response}
    });

    FigshareAPI->pushResponse({
        url => "$TEST_CONFIGURATION_7->{apiUrl}/articles?institution=$TEST_CONFIGURATION_7->{institutionId}&published_since=$TEST_CONFIGURATION_7->{publishedSince}&page=2",
        status => $PUBLICATIONS_SINCE_TERMINATOR->{status},
        response => $PUBLICATIONS_SINCE_TERMINATOR->{response},
    });

    foreach my $articleId (@ARTICLE_IDS) {
        FigshareAPI->pushResponse({
            url => "https://api.figshare.com/v2/articles/$articleId",
            status => 200,
            response => scalar slurp "t/Data/FigshareAPI/$articleId",
        });
    }

    $figshareAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_7->{_id});

    ok(time() - $configuration->{lastHarvested} < 10, 'We just harvested so the last harvested timestamp should be within the last 10 seconds.');

    my (undef, undef, undef, $day, $month, $year) = localtime(time());
    $month++;
    $year+=1900;

    is($configuration->{publishedSince}, sprintf("%04d-%02d-%02d",$year ,$month, $day), 'Harvesting should update the configurations publishedSince property.');

    cmp_deeply(FigshareAPI->getApiCalls(),
        bag(
            "$TEST_CONFIGURATION_7->{apiUrl}/articles?institution=$TEST_CONFIGURATION_7->{institutionId}&published_since=$originalPublishedSince&page=1",
            "$TEST_CONFIGURATION_7->{apiUrl}/articles?institution=$TEST_CONFIGURATION_7->{institutionId}&published_since=$originalPublishedSince&page=2",
            "https://api.figshare.com/v2/articles/2005377",
            "https://api.figshare.com/v2/articles/2002947",
            "https://api.figshare.com/v2/articles/2001129",
            "https://api.figshare.com/v2/articles/2000901",
            "https://api.figshare.com/v2/articles/2001888",
            "https://api.figshare.com/v2/articles/2001255",
            "https://api.figshare.com/v2/articles/2001054",
            "https://api.figshare.com/v2/articles/2000997",
        ),
        "In this case getDatasets should call the correct API URL"
    );

    my $items = $database->getItems();

    foreach my $item (@{$items}) {
        delete $item->{_id};
    }

    my @expectedItems;

    cmp_deeply($items,
        bag(
            $HARVESTED_ITEM_1, $HARVESTED_ITEM_2, $HARVESTED_ITEM_3, $HARVESTED_ITEM_4,
            $HARVESTED_ITEM_5, $HARVESTED_ITEM_6, $HARVESTED_ITEM_7, $HARVESTED_ITEM_8,
        ),
        "After harvesting our database should contain the items"
    );
}

sub dontHarvestTooOften : Test(1) {
    my $originalPublishedSince = $TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{publishedSince};

    FigshareAPI->pushResponse({
        url => "$TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{apiUrl}/articles?institution=$TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{institutionId}&published_since=$TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{publishedSince}&page=1",
        status => $PUBLICATIONS_SINCE_1->{status},
        response => $PUBLICATIONS_SINCE_1->{response}
    });

    FigshareAPI->pushResponse({
        url => "$TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{apiUrl}/articles?institution=$TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{institutionId}&published_since=$TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{publishedSince}&page=2",
        status => $PUBLICATIONS_SINCE_TERMINATOR->{status},
        response => $PUBLICATIONS_SINCE_TERMINATOR->{response},
    });

    foreach my $articleId (@ARTICLE_IDS) {
        FigshareAPI->pushResponse({
            url => "https://api.figshare.com/v2/articles/$articleId",
            status => 200,
            response => scalar slurp "t/Data/FigshareAPI/$articleId",
        });
    }

    my $figshareAgent = FigshareAgent->new({
        database => $database,
        configuration => $TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD,
    });
 
    $figshareAgent->harvest();

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD->{_id});

    ok(time() - $configuration->{lastHarvested} > 10, 'The last harvested timestamp should not have been updated.');

}

1;
