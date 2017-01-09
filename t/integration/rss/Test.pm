use strict;

use Database;
use Controller;
use Configuration;
use LupinAgent;
use TweetLog;
use TwitterAgent;
use RSSAPI;
use FacebookAgent;
 
package FacebookAgent;
 
my @posts;
 
sub clearPosts {
    @posts = ();
}

sub makePost {
    my ($self, $post) = @_;

    $self->logPost($post);

    push @posts, $post;
}

sub getPost {
    return pop @posts;
}
 
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
    $INTEGRATION_CONFIGURATION_5 $INTEGRATION_CONFIGURATION_6 $INTEGRATION_CONFIGURATION_8
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

    $TITLE_TWEET_ITEM_1  $TITLE_TWEET_ITEM_2  $TITLE_TWEET_ITEM_3  $TITLE_TWEET_ITEM_4
    $TITLE_TWEET_ITEM_5  $TITLE_TWEET_ITEM_6  $TITLE_TWEET_ITEM_7  $TITLE_TWEET_ITEM_8
    $TITLE_TWEET_ITEM_9  $TITLE_TWEET_ITEM_10 $TITLE_TWEET_ITEM_11 $TITLE_TWEET_ITEM_12
    $TITLE_TWEET_ITEM_13 $TITLE_TWEET_ITEM_14 $TITLE_TWEET_ITEM_15 $TITLE_TWEET_ITEM_16

    $TITLE_POST_ITEM_1  $TITLE_POST_ITEM_2  $TITLE_POST_ITEM_3  $TITLE_POST_ITEM_4
    $TITLE_POST_ITEM_5  $TITLE_POST_ITEM_6  $TITLE_POST_ITEM_7  $TITLE_POST_ITEM_8
    $TITLE_POST_ITEM_9  $TITLE_POST_ITEM_10 $TITLE_POST_ITEM_11 $TITLE_POST_ITEM_12
    $TITLE_POST_ITEM_13 $TITLE_POST_ITEM_14 $TITLE_POST_ITEM_15 $TITLE_POST_ITEM_16
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

    $database->saveConfiguration($INTEGRATION_CONFIGURATION_5);
    $database->saveConfiguration($INTEGRATION_CONFIGURATION_6);
    $database->saveConfiguration($INTEGRATION_CONFIGURATION_8);
}


sub integration : Test(16) {
    my $controller=Controller->new({
        database => $database,
    });
    isa_ok($controller, 'Controller');

    #
    # prepare the fake http responses for the harvesting agents
    #
    RSSAPI->clearResponses();
    RSSAPI->clearApiCalls();

    RSSAPI->pushResponse({
        url => $RSS_FEED_1->{url},
        status => $RSS_FEED_1->{status},
        response => $RSS_FEED_1->{response},
    });

    FacebookAgent->clearPosts();

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
    cmp_deeply(
        RSSAPI->getApiCalls(),
        bag(
            $RSS_FEED_1->{url},
        ),
        "In this case getItems should make one call to our Feed's url"
    );

    my $items = $database->getItems();

    foreach my $item (@{$items}) {
        delete $item->{_id};
    }

    my @expectedItems;

    cmp_deeply($items,
        bag(
            $HARVESTED_ITEM_1,  $HARVESTED_ITEM_2,  $HARVESTED_ITEM_3,  $HARVESTED_ITEM_4,
            $HARVESTED_ITEM_5,  $HARVESTED_ITEM_6,  $HARVESTED_ITEM_7,  $HARVESTED_ITEM_8,
            $HARVESTED_ITEM_9,  $HARVESTED_ITEM_10, $HARVESTED_ITEM_11, $HARVESTED_ITEM_12,
            $HARVESTED_ITEM_13, $HARVESTED_ITEM_14, $HARVESTED_ITEM_15, $HARVESTED_ITEM_16,
        ),
        "After harvesting our database should contain the items"
    );

    #
    # Check that harvesting agents don't harvest too often
    #

    my $configuration = $database->getConfiguration($INTEGRATION_CONFIGURATION_5->{_id}->{value});
    my $lastHarvested = $configuration->{lastHarvested};

    sleep 1;

    foreach my $harvestingAgent (@{$harvestingAgents}) {
        $harvestingAgent->harvest();
    }

    $configuration = $database->getConfiguration($INTEGRATION_CONFIGURATION_5->{_id}->{value});

    is($configuration->{lastHarvested}, $lastHarvested, 'Requesting a harvest too soon should not harvest or update teh last harvested parameter should update the configurations publishedSince property.');


    #
    # prepare for the publishing tests
    #

    my $beforeTwitterAgentStatus = getItemStatuses($INTEGRATION_CONFIGURATION_6->{title});
    my $beforeFacebookAgentStatus = getItemStatuses($INTEGRATION_CONFIGURATION_8->{title});

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
    
    my $afterTwitterAgentStatus = getItemStatuses($INTEGRATION_CONFIGURATION_6->{title});
    my $afterFacebookAgentStatus = getItemStatuses($INTEGRATION_CONFIGURATION_8->{title});

    ok($afterTwitterAgentStatus->{none} == 0, "There shouldn't be any items without a status for the publishing agent after they've run.");
    is($afterTwitterAgentStatus->{Pending}, $beforeTwitterAgentStatus->{Pending} + $beforeTwitterAgentStatus->{none} - 1, "We should have a lot of pending status (those pending before plus those without a status before minus the one actually tweeted).");
    is($afterTwitterAgentStatus->{'Pending ICYMI'}, $beforeTwitterAgentStatus->{'Pending ICYMI'}, "We should have the same number of ICYMI tweets as ICYMI is disabled");
    is($beforeTwitterAgentStatus->{Done} + 1, $afterTwitterAgentStatus->{Done}, "We should have one more Done item.");
    
    my $tweetMade = TwitterAgent->getTweet();

    my $validTweet = List::MoreUtils::any {$_ eq $tweetMade} (
        $TITLE_TWEET_ITEM_1,  $TITLE_TWEET_ITEM_2,  $TITLE_TWEET_ITEM_3,  $TITLE_TWEET_ITEM_4,
        $TITLE_TWEET_ITEM_5,  $TITLE_TWEET_ITEM_6,  $TITLE_TWEET_ITEM_7,  $TITLE_TWEET_ITEM_8,
        $TITLE_TWEET_ITEM_9,  $TITLE_TWEET_ITEM_10, $TITLE_TWEET_ITEM_11, $TITLE_TWEET_ITEM_12,
        $TITLE_TWEET_ITEM_13, $TITLE_TWEET_ITEM_14, $TITLE_TWEET_ITEM_15, $TITLE_TWEET_ITEM_16,
    );

    ok($validTweet, 'tweet made should be an expected one.');

    my $twitterAgentConfiguration = $database->getConfiguration($INTEGRATION_CONFIGURATION_6->{_id}->{value});

    ok($twitterAgentConfiguration->{lastTweeted} > time() - 10, 'last tweeted timestamp for the twitter agent should be within the last 10 seconds');

    ok($afterFacebookAgentStatus->{none} == 0, "There shouldn't be any items without a status for the publishing agent after they've run.");
    is($afterFacebookAgentStatus->{Pending}, $beforeFacebookAgentStatus->{Pending} + $beforeFacebookAgentStatus->{none} - 1, "We should have a lot of pending status (those pending before plus those without a status before minus the one actually tweeted).");
    is($afterFacebookAgentStatus->{'Pending ICYMI'}, $beforeFacebookAgentStatus->{'Pending ICYMI'}, "We should have the same number of ICYMI tweets as ICYMI is disabled");
    is($beforeFacebookAgentStatus->{Done} + 1, $afterFacebookAgentStatus->{Done}, "We should have one more Done item.");
 
    my $postMade = FacebookAgent->getPost();
    cmp_deeply(
        [$postMade],
        subbagof(
            $TITLE_POST_ITEM_1,  $TITLE_POST_ITEM_2,  $TITLE_POST_ITEM_3,  $TITLE_POST_ITEM_4,
            $TITLE_POST_ITEM_5,  $TITLE_POST_ITEM_6,  $TITLE_POST_ITEM_7,  $TITLE_POST_ITEM_8,
            $TITLE_POST_ITEM_9,  $TITLE_POST_ITEM_10, $TITLE_POST_ITEM_11, $TITLE_POST_ITEM_12,
            $TITLE_POST_ITEM_13, $TITLE_POST_ITEM_14, $TITLE_POST_ITEM_15, $TITLE_POST_ITEM_16,
        ),
        'post should be an expected one.'
    );

    my $facebookAgentConfiguration = $database->getConfiguration($INTEGRATION_CONFIGURATION_8->{_id}->{value});

    ok($facebookAgentConfiguration->{lastPosted} > time() - 10, 'last posted timestamp for the facebook agent should be within the last 10 seconds');


}

sub getItemStatuses {
    my ($agent) = @_;

    my $statuses = {
        none => 0,
        Done => 0,
        Pending => 0,
        'Pending ICYMI' => 0,
    };
    my $items = $database->getItems();
    foreach my $item (@{$items}) {
        my $status = $item->{statuses}->{$agent} || 'none';

        if (!$statuses->{$status}) {
            $statuses->{$status} = 0;
        }
        $statuses->{$status}++;
    }

    return $statuses;
}

1;
