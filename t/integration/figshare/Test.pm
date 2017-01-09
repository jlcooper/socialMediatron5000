use strict;

use Database;
use Controller;
use Configuration;
use LupinAgent;
use TweetLog;
use TwitterAgent;
use FigshareAgent;

package TwitterAgent;

my @tweets;

sub clearTweets {
    @tweets = ();
}

sub makeTweet {
    my ($self, $tweet) = @_;

    push @tweets, $tweet;
}

sub getTweet {
    return pop @tweets;
}

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



package Integration::Test;

use base 'Test::Class';

use Test::More;
use Test::Exception;
use Test::Deep;

use Carp;
use Readonly;
use Perl6::Slurp;
use List::MoreUtils;
use Data::Dumper;

use Data::TestConfigurations qw(
    $INTEGRATION_CONFIGURATION_1 $INTEGRATION_CONFIGURATION_2
);

use Data::TestFigshareAPI qw(
    $PUBLICATIONS_SINCE_1 $PUBLICATIONS_SINCE_TERMINATOR

    $PUBLICATION_1 $HARVESTED_ITEM_1 $TITLE_TWEET_ITEM_1
    $PUBLICATION_2 $HARVESTED_ITEM_2 $TITLE_TWEET_ITEM_2
    $PUBLICATION_3 $HARVESTED_ITEM_3 $TITLE_TWEET_ITEM_3
    $PUBLICATION_4 $HARVESTED_ITEM_4 $TITLE_TWEET_ITEM_4
    $PUBLICATION_5 $HARVESTED_ITEM_5 $TITLE_TWEET_ITEM_5
    $PUBLICATION_6 $HARVESTED_ITEM_6 $TITLE_TWEET_ITEM_6
    $PUBLICATION_7 $HARVESTED_ITEM_7 $TITLE_TWEET_ITEM_7
    $PUBLICATION_8 $HARVESTED_ITEM_8 $TITLE_TWEET_ITEM_8

    @ARTICLE_IDS
);

use Settings qw( $TEST_DATABASE_HOST $TEST_DATABASE_PORT $TEST_DATABASE_NAME );

my $mongoClient;
my $dbh;
my $database;


sub startUp : Test(startup) {
    $mongoClient = MongoDB::MongoClient->new(host => $TEST_DATABASE_HOST, port => $TEST_DATABASE_PORT) or croak "unable to access database host or port";
    $dbh = $mongoClient->get_database($TEST_DATABASE_NAME) or croak "unable to access database";

    if (my $configurations = $dbh->get_collection( 'configurations' )) {
        $configurations->drop();
    }

    my $configurations = $dbh->get_collection('configurations');

    if (my $items = $dbh->get_collection( 'items' )) {
        $items->drop();
    }

    my $items = $dbh->get_collection('items');

    $database = Database->new({
        databaseHost => $TEST_DATABASE_HOST,
        databasePort => $TEST_DATABASE_PORT,
        databaseName => $TEST_DATABASE_NAME,
    });

    $database->saveConfiguration($INTEGRATION_CONFIGURATION_1);
    $database->saveConfiguration($INTEGRATION_CONFIGURATION_2);
}


sub integration : Test(11) {
    my $controller=Controller->new({
        database => $database,
    });
    isa_ok($controller, 'Controller');

    #
    # prepare the fake http responses for the harvesting agents
    #

    my $originalPublishedSince = $INTEGRATION_CONFIGURATION_1->{publishedSince};

    FigshareAPI->pushResponse({
        url => "$INTEGRATION_CONFIGURATION_1->{apiUrl}/articles?institution=$INTEGRATION_CONFIGURATION_1->{institutionId}&published_since=$INTEGRATION_CONFIGURATION_1->{publishedSince}&page=1",
        status => $PUBLICATIONS_SINCE_1->{status},
        response => $PUBLICATIONS_SINCE_1->{response}
    });

    FigshareAPI->pushResponse({
        url => "$INTEGRATION_CONFIGURATION_1->{apiUrl}/articles?institution=$INTEGRATION_CONFIGURATION_1->{institutionId}&published_since=$INTEGRATION_CONFIGURATION_1->{publishedSince}&page=2",
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

    #
    # run the harvesting agents
    #

    my $harvestingAgents = $controller->getHarvestingAgents();

    foreach my $harvestingAgent (@{$harvestingAgents}) {
        $harvestingAgent->harvest();
    }

    #
    # tests to perform after harvesting agents have run
    #

    my $configuration = $database->getConfiguration($INTEGRATION_CONFIGURATION_1->{_id}->{value});

    my (undef, undef, undef, $day, $month, $year) = localtime(time());
    $month++;
    $year+=1900;

    is($configuration->{publishedSince}, sprintf("%04d-%02d-%02d", $year, $month, $day), 'Harvesting should update the configurations publishedSince property.');

    cmp_deeply(FigshareAPI->getApiCalls(),
        bag(
            "$INTEGRATION_CONFIGURATION_1->{apiUrl}/articles?institution=$INTEGRATION_CONFIGURATION_1->{institutionId}&published_since=$originalPublishedSince&page=1",
            "$INTEGRATION_CONFIGURATION_1->{apiUrl}/articles?institution=$INTEGRATION_CONFIGURATION_1->{institutionId}&published_since=$originalPublishedSince&page=2",
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

    #
    # Check that harvesting agents don't harvest too often
    #

    my $lastHarvested = $configuration->{lastHarvested};

    sleep 1;

    foreach my $harvestingAgent (@{$harvestingAgents}) {
        $harvestingAgent->harvest();
    }

    my $configuration = $database->getConfiguration($INTEGRATION_CONFIGURATION_1->{_id}->{value});

    is($configuration->{lastHarvested}, $lastHarvested, 'Requesting a harvest too soon should not harvest or update teh last harvested parameter should update the configurations publishedSince property.');



    #
    # prepare for the publishing tests
    #

    my $beforeStatus = getItemStatuses();

    #
    # run the publishing agents
    #

    my $publishingAgents = $controller->getPublishingAgents();

    foreach my $publishingAgent (@{$publishingAgents}) {
        $publishingAgent->publish();
    }

    #
    # tests to perform after the harvesting agents have run
    #
    
    my $afterStatus = getItemStatuses();

    ok($afterStatus->{none} == 0, "There shouldn't be any items without a status for the publishing agent after they've run.");
    is($afterStatus->{Pending}, $beforeStatus->{Pending} + $beforeStatus->{none} - 1, "We should have a lot of pending status (those pending before plus those without a status before minus the one actually tweeted).");
    is($afterStatus->{'Pending ICYMI'}, $beforeStatus->{'Pending ICYMI'} + 1, "We should have one more pending ICYMI status from the pending one that was tweeted.");
    is($beforeStatus->{Done}, $afterStatus->{Done}, "Done before publishing shouldn't change.");
    
    my $tweetMade = TwitterAgent->getTweet();

    my $validTweet = List::MoreUtils::any {$_ eq $tweetMade} (
        $TITLE_TWEET_ITEM_1, $TITLE_TWEET_ITEM_2, $TITLE_TWEET_ITEM_3, $TITLE_TWEET_ITEM_4,
        $TITLE_TWEET_ITEM_5, $TITLE_TWEET_ITEM_6, $TITLE_TWEET_ITEM_7, $TITLE_TWEET_ITEM_8,
    );
    ok($validTweet, 'tweet made should be an expected one.');

    my $publisherConfiguration = $database->getConfiguration($INTEGRATION_CONFIGURATION_2->{_id}->{value});

    ok($publisherConfiguration->{lastTweeted} > time() - 10, 'last tweeted timestamp for the publishing agent should be within the last 10 seconds');
}

sub getItemStatuses {
    my ($self) = @_;

    my $statuses = {};
    my $items = $database->getItems();
    foreach my $item (@{$items}) {
        my $status = $item->{statuses}->{$INTEGRATION_CONFIGURATION_2->{title}} || 'none';

        if (!$statuses->{$status}) {
            $statuses->{$status} = 0;
        }
        $statuses->{$status}++;
    }

    return $statuses;
}
1;
