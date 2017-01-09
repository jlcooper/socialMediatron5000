use strict;

package Database::Test;

use base 'Test::Class';

use Database;
use Test::More;
use Test::Exception;
use Test::Deep;
use Data::Dumper;
use Carp;
use Clone qw(clone);

use MongoDB;

use Readonly;

use Data::TestConfigurations qw (
    $TEST_CONFIGURATION_1 $TEST_CONFIGURATION_2 $TEST_CONFIGURATION_3
    $TEST_CONFIGURATION_4
);

use Data::TestItems qw (
    $TEST_ITEM_1 $TEST_ITEM_2 $TEST_ITEM_3 $TEST_ITEM_5
    $TEST_ITEM_MISSING_STATUSES_1 $TEST_ITEM_MISSING_TIMESTAMPS_1 $TEST_ITEM_MISSING_STATUSES_AND_TIMESTAMPS_1
    $TEST_DUPLICATE_FIGSHARE_ITEM_1
);

use Data::TestTweets qw (
    $TEST_TWEET_1 $TEST_TWEET_2 $TEST_TWEET_3
    $TEST_TWEET_4
    $COMPARE_TWEET_1 $COMPARE_TWEET_2 $COMPARE_TWEET_3 $COMPARE_TWEET_4
);

use Data::TestPosts qw (
    $TEST_POST_1 $TEST_POST_2 $TEST_POST_3
    $TEST_POST_4
    $COMPARE_POST_1 $COMPARE_POST_2 $COMPARE_POST_3 $COMPARE_POST_4
);


use Data::TestRSSAPI qw (
    $HARVESTED_ITEM_1
);

use Settings qw(
    $DATABASE_HOST $DATABASE_PORT
);

Readonly my $DATABASE_NAME => 'testRDMTwitterBot';


my $mongoClient;
my $dbh;
my $database;


sub startUp : Test(startup) {
    $mongoClient = MongoDB::MongoClient->new(host => $DATABASE_HOST, port => $DATABASE_PORT) or croak "unable to access database host or port";
    $dbh = $mongoClient->get_database($DATABASE_NAME) or croak "unable to access database";

    if (my $configurations = $dbh->get_collection( 'configurations' )) {
        $configurations->drop();
    }

    my $configurations = $dbh->get_collection('configurations');

    $configurations->insert($TEST_CONFIGURATION_1);
    $configurations->insert($TEST_CONFIGURATION_2);
    $configurations->insert($TEST_CONFIGURATION_3);
    $configurations->insert($TEST_CONFIGURATION_4);

    $database = Database->new({
        databaseHost => $DATABASE_HOST,
        databasePort => $DATABASE_PORT,
        databaseName => $DATABASE_NAME,
    });
}


sub setup : Test(setup) {
    if (my $items = $dbh->get_collection( 'items' )) {
        $items->drop();
    }

    my $items = $dbh->get_collection('items');

    $items->insert($TEST_ITEM_1);
    $items->insert($TEST_ITEM_3);

    if (my $tweets = $dbh->get_collection( 'tweetLog' )) {
        $tweets->drop();
    }

    my $tweets = $dbh->get_collection('tweetLog');

    $tweets->insert($TEST_TWEET_1);
    $tweets->insert($TEST_TWEET_2);
    $tweets->insert($TEST_TWEET_3);

    if (my $posts = $dbh->get_collection( 'postLog' )) {
        $posts->drop();
    }

    my $posts = $dbh->get_collection('postLog');

    $posts->insert($TEST_POST_1);
    $posts->insert($TEST_POST_2);
    $posts->insert($TEST_POST_3);
}


sub teardown : Test(teardown) {

}


sub _new : Test(2) {
    isa_ok($database, 'Database');

    throws_ok {Database->new()} qr/missing required parameters/;
}


sub getConfiguration : Test(2) {
    throws_ok {$database->getConfiguration()} qr/missing required parameters/;

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_1->{_id}->{value});

    cmp_deeply($configuration, noclass($TEST_CONFIGURATION_1), 'Should get back our test configuration');
}


sub getConfigurationWithProperities : Test(2) {
    my $harvestingAgents = $database->getConfigurationsWithProperties(['harvester']);

    ok(scalar @{$harvestingAgents} == 3, 'We should have found 3 configurations with the harvesting property');
    cmp_deeply($harvestingAgents, bag($TEST_CONFIGURATION_1, $TEST_CONFIGURATION_2, $TEST_CONFIGURATION_3), 'harvesting agent configs should match the ones we saved');
}

sub getActiveConfigurationWithProperities : Test(2) {
    my $harvestingAgents = $database->getActiveConfigurationsWithProperties(['harvester']);

    ok(scalar @{$harvestingAgents} == 2, 'We should have found 2 configurations with the harvesting property');
    cmp_deeply($harvestingAgents, bag($TEST_CONFIGURATION_1, $TEST_CONFIGURATION_2), 'harvesting agent configs should match the active ones we saved');
}


sub saveConfiguration : Test(3) {
    my $configuration = {
        title => 'Test Configuration 2',
    };

    throws_ok {$database->saveConfiguration()} qr/missing required parameters/;

    my $configurationId = $database->saveConfiguration($configuration);

    my $retrievedConfiguration = $database->getConfiguration($configurationId);

    cmp_deeply($retrievedConfiguration, superhashof($configuration), 'saved configurations should be the same when retrieved');

    $configuration->{_id} = MongoDB::OID->new($configurationId);
    $configuration->{state} = 'active';

    $database->saveConfiguration($configuration);
    $retrievedConfiguration = $database->getConfiguration($configurationId);

    delete $configuration->{_id};

    cmp_deeply($retrievedConfiguration, superhashof($configuration), 'updated configurations should be the same when retrieved');
}

sub updateConfigurationField : Test(2) {
    my $configuration = {
        title => 'Test Configuration 2',
    };

    throws_ok {$database->updateConfigurationField()} qr/missing required parameters/;

    my $configurationId = $database->saveConfiguration($configuration);

    $database->updateConfigurationField($configurationId, 'title', 'Test Title');

    my $retrievedConfiguration = $database->getConfiguration($configurationId);

    cmp_deeply($retrievedConfiguration->{title}, 'Test Title', 'updated configuration fields should be correct when retrieved');
}



sub getItems : Test(7) {
    throws_ok {$database->getItems('asdf')} qr/parameter mush be a hash reference/;

    my $items = $database->getItems();
  
    ok(scalar @$items == 2, 'getItems should only find two entries at this point');
    cmp_deeply($items, bag($TEST_ITEM_1, $TEST_ITEM_3), 'getItems should return our test entries');

    $items = $database->getItems({"statuses.Test Publisher 1" => 'Pending'});
    ok(scalar @$items == 1, 'getItems should only find one item as pending for "Test Publisher 1"');
    cmp_deeply($items, bag($TEST_ITEM_1), 'getItems should return our test peneding "Test Publisher 1" entry');

    $items = $database->getItems({"statuses.Test Publisher 2" => {'$exists' => 0}});
    ok(scalar @$items == 1, 'getItems should only find one item without an "Test Publisher 2" status');
    cmp_deeply($items, bag($TEST_ITEM_3), 'getItems should return our entry without an "Test Publisher 2" status');
}

sub getItemsWithoutStatusFor : Test(3) {
    throws_ok {$database->getItemsWithoutStatusFor()} qr/missing required parameters/;

    my $items = $database->getItemsWithoutStatusFor('Test Publisher 2');
    ok(scalar @$items == 1, 'getItems should only find one item without an "Test Publisher 2" status');
    cmp_deeply($items, bag($TEST_ITEM_3), 'getItems should return our entry without an "Test Publisher 2" status');
}

sub getItemsWithStatusFor : Test(6) {
    throws_ok {$database->getItemsWithStatusFor()} qr/missing required parameters/;
    throws_ok {$database->getItemsWithStatusFor('asdf')} qr/parameter mush be a hash reference/;

    my $items = $database->getItemsWithStatusFor({
        agent => "Test Publisher 1",
        status => 'Pending',
    });

    ok(scalar @$items == 1, 'getItemsWithStatusFor should only find one item as pending for "Test Publisher 1"');
    cmp_deeply($items, bag($TEST_ITEM_1), 'getItemsWithStatusFor should return our test peneding "Test Publisher 1" entry');

    my $itemCollection = $dbh->get_collection('items');
    $itemCollection->insert($TEST_ITEM_2);
    $itemCollection->insert($TEST_ITEM_5);

    my $items = $database->getItemsWithStatusFor({
        agent => "Test Publisher 1",
        status => 'Pending ICYMI',
        limit => 1,
    });

    foreach my $item (@{$items}) {
        if ($item->{_id}) {
            delete $item->{_id};
        }
    }

    ok(scalar @$items == 1, 'getItemsWithStatusFor should only find one item as pending ICYMI for "Test Publisher 1"');

    my $testItem5WithOutId = $TEST_ITEM_5;
    delete $testItem5WithOutId->{_id};

    cmp_deeply($items, bag($testItem5WithOutId), 'getItemsWithStatusFor should return our test peneding ICYMI "Test Publisher 1" entry');

}

sub saveItems : Test(4) {
    throws_ok {$database->saveItem()} qr/missing required parameter/;
    throws_ok {$database->saveItem('asdf')} qr/item should be a hash reference/;

    $database->saveItem($TEST_ITEM_2);
    my $items = $database->getItems();
  
    ok(scalar @{$items} == 3, 'getItems should find two entries at this point');

    foreach my $item (@{$items}) {
        if ($item->{_id}) {
            delete $item->{_id};
        }
    }

    my $testItem1WithOutId = $TEST_ITEM_1;
    delete $testItem1WithOutId->{_id};
    my $testItem3WithOutId = $TEST_ITEM_3;
    delete $testItem3WithOutId->{_id};

    cmp_deeply($items, bag($testItem1WithOutId, $testItem3WithOutId, $TEST_ITEM_2), 'getItems should return our three test entries');
}

sub saveDuplicateItems : Test(2) {
    $database->saveItem($TEST_DUPLICATE_FIGSHARE_ITEM_1);
    $database->saveItem($TEST_DUPLICATE_FIGSHARE_ITEM_1);
    $database->saveItem($HARVESTED_ITEM_1);
    $database->saveItem($HARVESTED_ITEM_1);

    my $items = $database->getItems();
 
    ok(scalar @{$items} == 4, 'getItems should find four entries at this point');

    foreach my $item (@{$items}) {
        if ($item->{_id}) {
            delete $item->{_id};
        }
    }

    my $testItem1WithOutId = $TEST_ITEM_1;
    delete $testItem1WithOutId->{_id};
    my $testItem3WithOutId = $TEST_ITEM_3;
    delete $testItem3WithOutId->{_id};


    cmp_deeply($items, bag($testItem1WithOutId, $testItem3WithOutId, $TEST_DUPLICATE_FIGSHARE_ITEM_1, $HARVESTED_ITEM_1), 'getItems should return our four test entries');
}


sub saveItemsAddsStatuses : Test(1) {
    $database->saveItem($TEST_ITEM_MISSING_STATUSES_1);

    my $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_STATUSES_1->{_id}})};

    is(ref $item->{statuses}, "HASH", "saveItem should add a statuses property if item doesn't have one.");
}

sub saveItemsAddsTimestamps : Test(1) {
    $database->saveItem($TEST_ITEM_MISSING_TIMESTAMPS_1);

    my $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_TIMESTAMPS_1->{_id}})};

    is(ref $item->{timestamps}, "HASH", "saveItem should add a timestamps property if item doesn't have one.");
}

sub saveItemsAddsStatusesAndTimestamps : Test(2) {
    $database->saveItem($TEST_ITEM_MISSING_STATUSES_AND_TIMESTAMPS_1);

    my $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_STATUSES_AND_TIMESTAMPS_1->{_id}})};

    is(ref $item->{statuses}, "HASH", "saveItem should add a statuses property if item doesn't have one.");
    is(ref $item->{timestamps}, "HASH", "saveItem should add a timestamps property if item doesn't have one.");
}

sub saveItemsDoesntOverwriteStatuses : Test(1) {
    $database->saveItem($TEST_ITEM_MISSING_STATUSES_1);

    my $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_STATUSES_1->{_id}})};

    $item->{statuses}->{asdf} = 1;

    $database->saveItem($item);

    delete $item->{statuses};

    $database->saveItem($item);
    
    $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_STATUSES_1->{_id}})};

    is($item->{statuses}->{asdf}, 1, "Saving a item without a statuses entry shouldn't remove the existing statuses entry if item is already in the database");
}

sub saveItemsDoesntOverwriteTimestamps : Test(1) {
    $database->saveItem($TEST_ITEM_MISSING_STATUSES_1);

    my $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_STATUSES_1->{_id}})};

    $item->{timestamps}->{asdf} = 1;

    $database->saveItem($item);

    delete $item->{timestamps};

    $database->saveItem($item);
    
    $item = pop @{$database->getItems({'_id' => $TEST_ITEM_MISSING_STATUSES_1->{_id}})};

    is($item->{timestamps}->{asdf}, 1, "Saving a item without a statuses entry shouldn't remove the existing timestamp entry if item is already in the database");
}


sub getTweets : Test(5) {
    throws_ok {$database->getTweets('asdf')} qr/parameter must be a hash reference/;

    my $tweets = $database->getTweets();

    ok(scalar @$tweets == 3, 'getTweets should only find three tweets at this point');
    cmp_deeply($tweets, bag($COMPARE_TWEET_1, $COMPARE_TWEET_2, $COMPARE_TWEET_3), 'getTweets should return our test entries');

    $tweets = $database->getTweets({agent => 'Agent1'});

    ok(scalar @$tweets == 2, 'getTweets should find two tweets for Agent1 at this point');
    cmp_deeply($tweets, bag($COMPARE_TWEET_1, $COMPARE_TWEET_2), 'getTweets should return our two tweets for Agent1');
}


sub saveTweet : Test(3) {
    throws_ok {$database->saveTweet('asdf')} qr/tweet must be a hash reference/;

    $database->saveTweet($TEST_TWEET_4);
    my $tweets = $database->getTweets();
  
    ok(scalar @$tweets == 4, 'getTweets should find four tweets at this point');
    cmp_deeply($tweets, bag($COMPARE_TWEET_1, $COMPARE_TWEET_2, $COMPARE_TWEET_3, $COMPARE_TWEET_4), 'getTweets should return our test entries including the one we just saved');
}

sub getPosts : Test(5) {
    throws_ok {$database->getPosts('asdf')} qr/parameter must be a hash reference/;

    my $posts = $database->getPosts();

    ok(scalar @$posts == 3, 'getTweets should only find three tweets at this point');
    cmp_deeply($posts, bag($COMPARE_POST_1, $COMPARE_POST_2, $COMPARE_POST_3), 'getPosts should return our test entries');

    $posts = $database->getPosts({agent => 'Agent1'});

    ok(scalar @$posts == 2, 'getPosts should find two posts for Agent1 at this point');
    cmp_deeply($posts, bag($COMPARE_POST_1, $COMPARE_POST_2), 'getTweets should return our two tweets for Agent1');
}


sub savePost : Test(3) {
    throws_ok {$database->savePost('asdf')} qr/post must be a hash reference/;

    $database->savePost($TEST_POST_4);
    my $posts = $database->getPosts();
  
    ok(scalar @$posts == 4, 'getTweets should find four tweets at this point');
    cmp_deeply($posts, bag($COMPARE_POST_1, $COMPARE_POST_2, $COMPARE_POST_3, $COMPARE_POST_4), 'getPosts should return our test entries including the one we just saved');
}


1;
