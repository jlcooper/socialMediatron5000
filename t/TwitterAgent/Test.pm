use strict;


use TwitterAgent;

package TwitterAgent;

my @tweets;

sub clearTweets {
    @tweets = ();
}

sub makeTweet {
    my ($self, $tweet) = @_;

    $self->logTweet($tweet);

    push @tweets, $tweet;
}

sub getTweet {
    return pop @tweets;
}

package TwitterAgent::Test;

use base 'Test::Class';

use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Data::Dumper;
use Clone qw(clone);

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_4 $TEST_CONFIGURATION_4_WITHOUT_ICYMI $TEST_CONFIGURATION_4_WITH_SOURCE
);

use Data::TestItems qw(
    $TEST_ITEM_1 $TEST_ITEM_2 $TEST_ITEM_3 $TEST_ITEM_4 $TEST_ITEM_5 $TEST_ITEM_6 $TEST_ITEM_7
);

my $database;
my $twitterAgent;


sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration(clone ($TEST_CONFIGURATION_4));
    $database->saveConfiguration(clone ($TEST_CONFIGURATION_4_WITH_SOURCE));

    $twitterAgent = TwitterAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_4),
    });
    $twitterAgent->clearTweets();
}


sub _new : Test(2) {
    throws_ok {TwitterAgent->new()} qr/missing required parameters/;
    
    isa_ok($twitterAgent, 'TwitterAgent');
}


sub prepareNewTweets : Test(1) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_4));

    $twitterAgent->prepareTweets();

    my $items = $database->getItems();
    my $validStatuses = 1;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_4->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this twitter agent');
}

sub formatTweet : Test(6) {
    my $tweetText = $twitterAgent->formatTweet({
        order => ['hashtags', 'title', 'doi'],
        shortenToFit => 'title',
        hashtags => ['#dataset', '#publication'],
        title => 'title',
        doi => 'http://doi.url.goes.here',
    });

    is($tweetText, '#dataset, #publication title http://doi.url.goes.here', 'Tweet should be formatted as specified');

    $tweetText = $twitterAgent->formatTweet({
        prepend => 'icymi..',
        order => ['hashtags', 'title', 'doi'],
        shortenToFit => 'title',
        hashtags => ['#dataset', '#publication'],
        title => 'title',
        doi => 'http://doi.url.goes.here',
    });

    is($tweetText, 'icymi.. #dataset, #publication title http://doi.url.goes.here', 'Tweet should be formatted as specified');

    $tweetText = $twitterAgent->formatTweet({
        prepend => 'icymi..',
        order => ['hashtags', 'title', 'doi'],
        shortenToFit => 'title',
        hashtags => ['#dataset', '#publication'],
        title => 'title' x 140,
        doi => 'http://doi.url.goes.here',
    });

    is(
        $tweetText,
        'icymi.. #dataset, #publication titletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitlet... http://doi.url.goes.here',
        , 'Tweet should be formatted as specified');

    is(length($tweetText), 140, 'tweet should be 140 characters in length');

    $tweetText = $twitterAgent->formatTweet({
        prepend => 'icymi..',
        order => ['hashtags', 'title', 'doi'],
        shortenToFit => 'title',
        hashtags => ['#dataset', '#publication'],
        title => [
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title'
        ],
        doi => 'http://doi.url.goes.here',
    });

    is(
        $tweetText,
        'icymi.. #dataset, #publication title, title, title, title, title, title, title, title, title, title, title, titl... http://doi.url.goes.here',
        , 'Tweet should be formatted as specified');

    is(length($tweetText), 140, 'tweet should be 140 characters in length');

}

sub sendICYMITweet : Test(2) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_4));
    $database->saveItem(clone($TEST_ITEM_5));

    my $items = $database->getItems();

    my $pendingICYMI = 0;
    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMI++;
        }
    }

    $twitterAgent->sendICYMITweet();

    $items = $database->getItems();

    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMI--;
        }
    }

    ok($pendingICYMI == 1, 'After making a ICYMI tweet we should have one less "Pending ICYMI" status for this twitter agent');

    is($twitterAgent->getTweet(), $TEST_ITEM_5->{icymiTweet}, 'ICYMI tweet should be the text expected.');
}

sub dontSendICYMITweetWithinThreshold : Test(2) {
    $database->saveItem(clone($TEST_ITEM_6));

    my $items = $database->getItems();

    my $pendingICYMI = 0;
    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMI++;
        }
    }

    my $tweetTookPlace = $twitterAgent->sendICYMITweet();

    is($tweetTookPlace, undef, "An ICYMI tweet shouldn't have taken place.");

    $items = $database->getItems();

    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMI--;
        }
    }

    is($pendingICYMI, 0, 'After making a ICYMI tweet we should have the same number of "Pending ICYMI" statuses for this twitter agent');
}


sub sendTweet : Test(3) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_4));
    $database->saveItem(clone($TEST_ITEM_5));

    my $items = $database->getItems();
    my $pending = 0;
    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending") {
            $pending++;
        }
    }

    my $preTweets = $database->getTweets();

    $twitterAgent->sendTweet();

    $items = $database->getItems();
    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending") {
            $pending--;
        }
    }

    ok($pending == 1, 'After making a tweet we should have one less "Pending" status for this twitter agent');

    is($twitterAgent->getTweet(), $TEST_ITEM_1->{tweet}, 'tweet should be the text expected.');


    my $postTweets = $database->getTweets();

    is(scalar @{$preTweets}, scalar @{$postTweets} - 1, 'after running we should have another tweet in the tweetLog');
}
 

sub publishICYMI : Test(3) {
    $database->saveItem(clone($TEST_ITEM_3));
    $database->saveItem(clone($TEST_ITEM_5));

    my $pendingICYMIbeforePulishing = 0;
    my $items = $database->getItems();

    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMIbeforePulishing++;
        }
    }

    $twitterAgent->publish();

    $items = $database->getItems();

    my $validStatuses = 1;
    my $pendingICYMIafterPulishing = 0;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_4->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMIafterPulishing++;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this twitter agent');

    is($pendingICYMIafterPulishing, $pendingICYMIbeforePulishing - 1, 'After making a ICYMI tweet we should have one less "Pending ICYMI" status for this twitter agent');

    is($twitterAgent->getTweet(), $TEST_ITEM_5->{icymiTweet}, 'ICYMI tweet should be the text expected.');
}


sub publish : Test(4) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_5));

    my $pendingBeforePulishing = 0;
    my $pendingICYMIbeforePulishing = 0;
    my $items = $database->getItems();
    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}}) {
            if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending") {
                $pendingBeforePulishing++;
            }
            if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
                $pendingICYMIbeforePulishing++;
            }
        }
    }

    $twitterAgent->publish();

    $items = $database->getItems();

    my $validStatuses = 1;
    my $pendingAfterPulishing = 0;
    my $pendingICYMIafterPulishing = 0;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_4->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending") {
            $pendingAfterPulishing++;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMIafterPulishing++;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this twitter agent');

    is($pendingAfterPulishing, $pendingBeforePulishing - 1, 'After making a tweet we should have one less "Pending" status for this twitter agent');

    is($pendingICYMIafterPulishing, $pendingICYMIbeforePulishing + 1, 'After making a tweet we should have one more of "Pending ICYMI" status for this twitter agent');

    is($twitterAgent->getTweet(), $TEST_ITEM_1->{tweet}, 'tweet should be the text expected.');
}


sub publishWithoutICYMI : Test(5) {
    $twitterAgent = TwitterAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_4_WITHOUT_ICYMI),
    });
    $twitterAgent->clearTweets();

    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_5));

    my $pendingBeforePulishing = 0;
    my $pendingICYMIbeforePulishing = 0;
    my $doneBeforePublishing = 0;
    my $items = $database->getItems();

    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}}) {
            if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending") {
                $pendingBeforePulishing++;
            }

            if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
                $pendingICYMIbeforePulishing++;
            }

            if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Done") {
                $doneBeforePublishing++;
            }
        }
    }

    $twitterAgent->publish();

    $items = $database->getItems();

    my $validStatuses = 1;
    my $pendingAfterPulishing = 0;
    my $pendingICYMIafterPulishing = 0;
    my $doneAfterPublishing = 0;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_4->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_4->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending") {
            $pendingAfterPulishing++;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Pending ICYMI") {
            $pendingICYMIafterPulishing++;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_4->{title}} eq "Done") {
            $doneAfterPublishing++;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this twitter agent');

    is($pendingAfterPulishing, $pendingBeforePulishing - 1, 'After making a tweet we should have one less "Pending" status for this twitter agent');

    is($pendingICYMIafterPulishing, $pendingICYMIbeforePulishing, 'After making a tweet pendingICYMI should be the same for this twitter agent');

    is($doneAfterPublishing, $doneBeforePublishing + 1, 'After making a tweet Done statuses should have increaed by one');

    is($twitterAgent->getTweet(), $TEST_ITEM_1->{tweet}, 'tweet should be the text expected.');
}


sub tweetsSetTheLastTweetedTimestamp : Test(2) {
    $database->saveItem(clone($TEST_ITEM_7));

    my $tweetTookPlace = $twitterAgent->sendTweet();

    is($tweetTookPlace, 1, "A tweet should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_4->{_id});

    ok((time - $configuration->{lastTweeted}) < 10, 'After making a tweet the lastTweeted timestamp should be updated');
}


sub icymiTweetsSetTheLastTweetedTimestamp : Test(2) {
    $database->saveItem(clone($TEST_ITEM_5));

    my $tweetTookPlace = $twitterAgent->sendICYMITweet();

    is($tweetTookPlace, 1, "A icymi tweet should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_4->{_id});

    ok((time - $configuration->{lastTweeted}) < 10, 'After making an icymi tweet the lastTweeted timestamp should be updated');
}


sub tweetThresholdStopsTweeting : Test(4) {
    $database->saveItem(clone($TEST_ITEM_7));
    $database->saveItem(clone($TEST_ITEM_7));

    my $tweetTookPlace = $twitterAgent->sendTweet();

    is($tweetTookPlace, 1, "A tweet should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_4->{_id});
    my $lastTweeted = $configuration->{lastTweeted};

    ok((time - $lastTweeted) < 10, 'After making a tweet the lastTweeted timestamp should be updated');

    $tweetTookPlace = $twitterAgent->sendTweet();

    is($tweetTookPlace, undef, "A tweet shouldn't have taken place.");

    $configuration = $database->getConfiguration($TEST_CONFIGURATION_4->{_id});

    is($configuration->{lastTweeted}, $lastTweeted, "Tweets stopped by the threshold shouldn't update the lastTweeted timestamp");
}

sub tweetThresholdStopsIcymiTweeting : Test(4) {
    $database->saveItem(clone($TEST_ITEM_5));
    $database->saveItem(clone($TEST_ITEM_5));

    my $tweetTookPlace = $twitterAgent->sendICYMITweet();

    is($tweetTookPlace, 1, "A tweet should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_4->{_id});
    my $lastTweeted = $configuration->{lastTweeted};

    ok((time - $lastTweeted) < 10, 'After making a tweet the lastTweeted timestamp should be updated');

    $tweetTookPlace = $twitterAgent->sendICYMITweet();

    is($tweetTookPlace, undef, "A tweet shouldn't have taken place.");

    $configuration = $database->getConfiguration($TEST_CONFIGURATION_4->{_id});

    is($configuration->{lastTweeted}, $lastTweeted, "Tweets stopped by the threshold shouldn't update the lastTweeted timestamp");
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

    ok($twitterAgent->validItemType($item1), 'an item with just a type of dataset should be valid');
    ok($twitterAgent->validItemType($item2), 'an item with a type of dataset and publication should be valid');
    ok($twitterAgent->validItemType($item3), 'an item with a type of publication and dataset should be valid');
    ok(!$twitterAgent->validItemType($item4), 'an item with just a type of publication should not be valid');    
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

    ok($twitterAgent->validItemSource($item1), 'Sources should not matter when no source has been configured for agent');
    ok($twitterAgent->validItemSource($item2), 'Sources should not matter when no source has been configured for agent');
    ok($twitterAgent->validItemSource($item3), 'Sources should not matter when no source has been configured for agent');

    my $twitterAgentWithSource = TwitterAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_4_WITH_SOURCE),
    });

    ok($twitterAgentWithSource->validItemSource($item1), 'an item with just a source of http://www.lboro.ac.uk/ should be valid');
    ok(!$twitterAgentWithSource->validItemSource($item2), 'an item with just a source of http://www.google.com/ should not be valid');
    ok(!$twitterAgentWithSource->validItemSource($item3), 'an item without a source should not be valid');
}

1;
