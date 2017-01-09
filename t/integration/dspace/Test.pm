use strict;

use Database;
use Controller;
use Configuration;
use LupinAgent;
use TweetLog;
use TwitterAgent;
use EmailAgent;
use DspaceAgent;
use DspaceAPI;

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

package EmailAgent;

my @emails;

sub clearEmails {
    @emails = ();
}

sub sendEmail {
    my ($self, $email) = @_;

    push @emails, $email;
}

sub getEmail {
    return pop @emails;
}




#
# Mock out the actual routines that call Elements as we don't want to
# call it in our testing
#

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
use URI::Escape;

use Data::TestConfigurations qw(
    $INTEGRATION_CONFIGURATION_3 $INTEGRATION_CONFIGURATION_4 $INTEGRATION_CONFIGURATION_7
);

use Data::TestDspaceAPI qw(
    $PUBLICATIONS_SINCE_1 $PUBLICATIONS_SINCE_TERMINATOR

    $SETS_1 $SETS_2 $SETS_3 $SETS_4

    $SET_SPEC_TO_NAME_MAPPING

    $PUBLICATION_1 $PUBLICATION_2 $PUBLICATION_3 $PUBLICATION_4
    $PUBLICATION_5 $PUBLICATION_6 $PUBLICATION_7

    $TITLE_TWEET_ITEM_1 $TITLE_TWEET_ITEM_2 $TITLE_TWEET_ITEM_3 $TITLE_TWEET_ITEM_4
    $TITLE_TWEET_ITEM_5 $TITLE_TWEET_ITEM_6 $TITLE_TWEET_ITEM_7
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

    $database->saveConfiguration($INTEGRATION_CONFIGURATION_3);
    $database->saveConfiguration($INTEGRATION_CONFIGURATION_4);
    $database->saveConfiguration($INTEGRATION_CONFIGURATION_7);

    DspaceAPI->clearResponses();
    DspaceAPI->clearApiCalls();

    my $oaipmhUrl = $INTEGRATION_CONFIGURATION_3->{oaipmhBaseUrl};
    my $publishedSince = $INTEGRATION_CONFIGURATION_3->{publishedSince};

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


sub integration : Test(16) {
    my $controller=Controller->new({
        database => $database,
    });

    isa_ok($controller, 'Controller');

    #
    # prepare the fake http responses for the harvesting agents
    #

    my $originalPublishedSince = $INTEGRATION_CONFIGURATION_3->{publishedSince};
    my $oaipmhBaseUrl = $INTEGRATION_CONFIGURATION_3->{oaipmhBaseUrl};

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

    my $configuration = $database->getConfiguration($INTEGRATION_CONFIGURATION_3->{_id}->{value});

    my (undef, undef, undef, $day, $month, $year) = localtime(time() - (24 * 60 * 60));
    $month++;
    $year+=1900;

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
        "In this case getDatasets should call the correct API URL"
    );

    my $items = $database->getItems();

    foreach my $item (@{$items}) {
        delete $item->{_id};
        delete $item->{timestamps};
        delete $item->{statuses};
    }

    my @expectedItems;

    cmp_deeply($items,
        bag(
            $PUBLICATION_2, $PUBLICATION_4, $PUBLICATION_5
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

    my $configuration = $database->getConfiguration($INTEGRATION_CONFIGURATION_3->{_id}->{value});

    is($configuration->{lastHarvested}, $lastHarvested, 'Requesting a harvest too soon should not harvest or update teh last harvested parameter should update the configurations publishedSince property.');



    #
    # prepare for the publishing tests
    #

    my $beforeStatus = getItemStatuses($INTEGRATION_CONFIGURATION_4->{title});

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
    
    my $afterStatus = getItemStatuses($INTEGRATION_CONFIGURATION_4->{title});

    ok($afterStatus->{none} == 0, "There shouldn't be any items without a status for the publishing agent after they've run.");
    is($afterStatus->{Pending} , $beforeStatus->{Pending} + $beforeStatus->{none} - 1, "We should have a lot of pending status (those pending before plus those without a status before minus the one actually tweeted).");
    is($afterStatus->{'Pending ICYMI'}, $beforeStatus->{'Pending ICYMI'}, "We shouldn't have any more pending ICYMI status as ICYMI is disabled.");
    is($afterStatus->{Done}, $beforeStatus->{Done} || 1, "We should have one more Done status.");
    
    my $tweetMade = TwitterAgent->getTweet();

    my $validTweet = List::MoreUtils::any {$_ eq $tweetMade} (
        $TITLE_TWEET_ITEM_2, $TITLE_TWEET_ITEM_4, $TITLE_TWEET_ITEM_5
    );

    ok($validTweet, 'tweet made should be an expected one.');

    my $publisherConfiguration = $database->getConfiguration($INTEGRATION_CONFIGURATION_4->{_id}->{value});

    ok($publisherConfiguration->{lastTweeted} > time() - 10, 'last tweeted timestamp for the publishing agent should be within the last 10 seconds');

    #
    # Check the output of the EmailAgent
    #

    my $emailText = EmailAgent->getEmail();

    like($emailText,
        qr/^Latest items available:\n/s,
        'email should start with the header text'
    );

    like($emailText,
        qr/\t* Coherence of the lattice polarization in large-polaron motion https:\/\/dspace.lboro.ac.uk\/2134\/1310\n\n/s,
        'email should contain the first test item'
    );

    like($emailText,
        qr/\t* Genetic algorithm optimisation of a firewater deluge system https:\/\/dspace.lboro.ac.uk\/2134\/2309\n\n/s,
        'email should contain the second test item'
    );

    like($emailText,
        qr/\t* Using statistically designed experiments for safety system optimization https:\/\/dspace.lboro.ac.uk\/2134\/2399\n\n/s,
        'email should contain the third test item'
    );

    like($emailText,
        qr/\n---\nSocial Mediatron 5000\n$/s,
        'email should finish with the footer'
    );



}

sub getItemStatuses {
    my ($publishingAgent) = @_;

    my $statuses = {};
    my $items = $database->getItems();
    foreach my $item (@{$items}) {
        my $status = $item->{statuses}->{$publishingAgent} || 'none';

        if (!$statuses->{$status}) {
            $statuses->{$status} = 0;
        }
        $statuses->{$status}++;
    }

    return $statuses;
}
1;
