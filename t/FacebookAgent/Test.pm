use strict;


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
 
package FacebookAgent::Test;

use base 'Test::Class';

use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Data::Dumper;
use Clone qw(clone);

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_FACEBOOK_AGENT_1
);

use Data::TestRSSAPI qw(
    $RSS_FEED_1

    $ITEM_1 $ITEM_2 $ITEM_3 $ITEM_4 $ITEM_5
    $ITEM_6 $ITEM_7 $ITEM_8 $ITEM_9 $ITEM_10

    $HARVESTED_ITEM_1  $HARVESTED_ITEM_2  $HARVESTED_ITEM_3  $HARVESTED_ITEM_4
    $HARVESTED_ITEM_5  $HARVESTED_ITEM_6  $HARVESTED_ITEM_7  $HARVESTED_ITEM_8
    $HARVESTED_ITEM_9  $HARVESTED_ITEM_10 $HARVESTED_ITEM_11 $HARVESTED_ITEM_12
    $HARVESTED_ITEM_13 $HARVESTED_ITEM_14 $HARVESTED_ITEM_15 $HARVESTED_ITEM_16

    $TITLE_POST_ITEM_1  $TITLE_POST_ITEM_2
);

my $database;
my $facebookAgent;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration(clone ($TEST_CONFIGURATION_FACEBOOK_AGENT_1));

    $facebookAgent = FacebookAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_FACEBOOK_AGENT_1),
    });

    $facebookAgent->clearPosts();
}


sub _new : Test(2) {
    throws_ok {FacebookAgent->new()} qr/missing required parameters/;
    
    isa_ok($facebookAgent, 'FacebookAgent');
}


sub prepareNewPosts : Test(1) {
    $database->saveItem(clone($HARVESTED_ITEM_1));
    $database->saveItem(clone($HARVESTED_ITEM_4));

    $facebookAgent->preparePosts();

    my $items = $database->getItems();
    my $validStatuses = 1;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} !~ m/(?:Pending|Done)/) {
            $validStatuses = 0;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this facebook agent');
}

sub formatPost : Test(6) {
    my $postFields = $facebookAgent->formatPostFields({
        title => 'title',
        description => 'description',
        url => 'http://url.goes.here',
    });

    cmp_deeply(
        $postFields, 
        {
            message => "title\n\ndescription",
            link => 'http://url.goes.here'
        },

        'Title, description and link should create a suitable hash ref for Facebook`s Graph API'
    );

    $postFields = $facebookAgent->formatPostFields({
        title => 'title',
        url => 'http://url.goes.here',
    });

    cmp_deeply(
        $postFields, 

        {
            message => 'title',
            link => 'http://url.goes.here'
        },

        'Title and link should create a suitable hash ref for Facebook`s Graph API'
    );

    $postFields = $facebookAgent->formatPostFields({
        title => 'title',
        description => 'description'
    });

    cmp_deeply(
        $postFields, 

        {
            message => "title\n\ndescription",
        },
 
        'Title and description should create a suitable hash ref for Facebook`s Graph API'
    );

    $postFields = $facebookAgent->formatPostFields({
        title => 'title',
    });

    cmp_deeply(
        $postFields, 

        {
            message => 'title',
        },
 
        'Title on it`s own should create a suitable hash ref for Facebook`s Graph API'
    );

    $postFields = $facebookAgent->formatPostFields({
        description => 'description'
    });

    cmp_deeply(
        $postFields, 
        {
            message => 'description',
        },

        'description on it`s own should create a suitable hash ref for Facebook`s Graph API'
    );

    throws_ok( sub {$facebookAgent->formatPostFields({});}, qr/no fields to post/, 'missing all fields should throw an error'); 
}


sub publish : Test(4) {
    $database->saveItem(clone($HARVESTED_ITEM_1));
    $database->saveItem(clone($HARVESTED_ITEM_2));

    my $prePosts = $database->getPosts();

    $facebookAgent->publish();

    my $items = $database->getItems();

    my $validStatuses = 1;
    my $pendingAfterPulishing = 0;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} eq "Pending") {
            $pendingAfterPulishing++;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this facebook agent');

    is($pendingAfterPulishing, 1, 'After making a post we should have one less "Pending" status for this facebook agent');

    my $post = $facebookAgent->getPost();

    cmp_deeply(
        [$post],
        subbagof($TITLE_POST_ITEM_1, $TITLE_POST_ITEM_2),
        'post should be the text expected.'
    );

    my $postPosts = $database->getPosts();

    is(scalar @{$prePosts}, scalar @{$postPosts} - 1, 'after running we should have another post in the postLog');
}

sub postsSetTheLastPostedTimestamp : Test(2) {
    my $item =clone($HARVESTED_ITEM_1);

    $item->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} = 'Pending';

    $database->saveItem($item);

    my $postTookPlace = $facebookAgent->sendPost();

    is($postTookPlace, 1, "A post should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_FACEBOOK_AGENT_1->{_id});

    ok((time - $configuration->{lastPosted}) < 10, 'After making a post the lastPosted timestamp should be updated');
}


sub tweetThresholdStopsTweeting : Test(4) {
    my $item1 = clone($HARVESTED_ITEM_1);
    my $item2 = clone($HARVESTED_ITEM_2);

    $item1->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} = 'Pending';
    $item2->{statuses}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} = 'Pending';
    $item1->{timestamps}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} = 0;
    $item2->{timestamps}->{$TEST_CONFIGURATION_FACEBOOK_AGENT_1->{title}} = 0;

    $database->saveItem($item1);
    $database->saveItem($item2);

    my $postTookPlace = $facebookAgent->sendPost();

    is($postTookPlace, 1, "A post should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_FACEBOOK_AGENT_1->{_id});
    my $lastPosted = $configuration->{lastPosted};

    ok((time - $lastPosted) < 10, 'After making a post the lastPosted timestamp should be updated');

    $postTookPlace = $facebookAgent->sendPost();

    is($postTookPlace, undef, "A post shouldn't have taken place.");

    $configuration = $database->getConfiguration($TEST_CONFIGURATION_FACEBOOK_AGENT_1->{_id});

    is($configuration->{lastPosted}, $lastPosted, "Posts stopped by the threshold shouldn't update the lastPosted timestamp");
}


1;
