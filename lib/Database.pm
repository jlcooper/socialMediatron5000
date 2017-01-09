use strict;
use warnings;

package Database;

use Class::Std;
use Carp;
use MongoDB;
use List::Util qw( any );

use Readonly;

use Data::Dumper;

Readonly my $TWEET_LOG_COLLECTION => 'tweetLog';

my %databaseNames : ATTR;
my %databasePorts : ATTR;
my %databaseHosts : ATTR;
my %databaseHandles : ATTR;
my %mongoClients : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;
    
    if (!$parameters->{databaseHost} || !$parameters->{databaseName} || !$parameters->{databasePort}) {
        croak "missing required parameters";
    }

    $databaseNames{$objId} = $parameters->{databaseName};
    $databaseHosts{$objId} = $parameters->{databaseHost};
    $databasePorts{$objId} = $parameters->{databasePort};

    $mongoClients{$objId} = MongoDB::MongoClient->new(host => $databaseHosts{$objId}, port => $databasePorts{$objId}) or croak "unable to access database host or port";
    $databaseHandles{$objId} = $mongoClients{$objId}->get_database($databaseNames{$objId}) or croak "unable to access database";
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $databaseNames{$objId};
    delete $databaseHosts{$objId};
    delete $databasePorts{$objId};
    delete $databaseHandles{$objId};
    delete $mongoClients{$objId};
}

sub getConfiguration {
    my ($self, $configurationId) = @_;

    if (!$configurationId) {
        croak "missing required parameters";
    }

    my $objId = ident $self;

    my $configurations = $databaseHandles{$objId}->get_collection('configurations');

    my $configuration = $configurations->find({_id => MongoDB::OID->new(value => $configurationId)});

    if (!$configuration || !$configuration->has_next()) {
        croak "unknown configuration $configurationId";
    }
    
    return $configuration->next() || {};
}


sub getConfigurationsWithProperties {
    my ($self, $properties) = @_;

    my $objId = ident $self;

    my $configurations = $databaseHandles{$objId}->get_collection('configurations');

    my $validConfigurations = $configurations->find(
        {
            'properties' => {
                '$all' => $properties
            }
        }
    );

    my @allVallidConfigurations = $validConfigurations->all();

    return \@allVallidConfigurations;
}

sub getActiveConfigurationsWithProperties {
    my ($self, $properties) = @_;

    my $objId = ident $self;

    my $configurations = $databaseHandles{$objId}->get_collection('configurations');

    my $activeValidConfigurations = $configurations->find(
        {
            'active' => 1,
            'properties' => {
                '$all' => $properties
            }
        }
    );

    my @allActiveValidConfigurations = $activeValidConfigurations->all();

    return \@allActiveValidConfigurations;
}


sub saveConfiguration {
    my ($self, $configuration) = @_;

    if (!$configuration) {
        croak "missing required parameters";
    }

    my $objId = ident $self;

    my $configurations = $databaseHandles{$objId}->get_collection('configurations');

    my $configurationId = $configuration->{_id};

    if ($configurationId) {
        $configurations->update(
            {'_id' => $configuration->{_id}},
            $configuration,
            {upsert => 1},
        );
    } else {
        delete $configuration->{_id};
        $configurationId = $configurations->insert($configuration)->{value};
    }

    return $configurationId;
}


sub updateConfigurationField {
    my ($self, $configurationId, $field, $newValue) = @_;

    if (!defined $configurationId || !defined $field || !defined $newValue) {
        croak "missing required parameters";
    }

    my $objId = ident $self;

    if (ref $configurationId ne "MongoDB::OID") {
        $configurationId = MongoDB::OID->new(value => $configurationId);
    }

    my $configurations = $databaseHandles{$objId}->get_collection('configurations');

    $configurations->update(
        {'_id' => $configurationId},
        {
            '$set' => {
                $field => $newValue,
            },
        },
    );

    return $configurationId;
}


sub getItems {
    my ($self, $parameters) = @_;

    if ($parameters && ref $parameters ne "HASH") {
        croak "parameter mush be a hash reference";
    }

    my $objId = ident $self;

    my $items = $databaseHandles{$objId}->get_collection('items');

    my $foundItems = $items->find($parameters || {});

    return [$foundItems->all()];
}


sub getItemsWithoutStatusFor {
    my ($self, $agent) = @_;

    if (!$agent) {
        croak "missing required parameters";
    }

    my $objId = ident $self;

    my $items = $databaseHandles{$objId}->get_collection('items');

    my $itemsWithoutAgentStatus = $items->find(
        {"statuses.$agent" => {'$exists' => 0}}
    );

    return [$itemsWithoutAgentStatus->all()];
}

sub getItemsWithStatusFor {
    my ($self, $parameters) = @_;

    if (!$parameters) {
        croak "missing required parameters";
    }

    if (ref $parameters ne "HASH") {
        croak "parameter mush be a hash reference"
    }

    my $objId = ident $self;

    my $items = $databaseHandles{$objId}->get_collection('items');

    my $query = {
        "statuses.$parameters->{agent}" => $parameters->{status}
    };

    my $itemsWithAgentStatus = $items->find($query);

    if ($parameters->{'limit'}) {
        $itemsWithAgentStatus->sort({"timestamps.$parameters->{agent}" => 1})->limit($parameters->{'limit'});       
    }
    return [$itemsWithAgentStatus->all()];
}


sub saveItem {
    my ($self, $item) = @_;

    my $objId = ident $self;

    if (!$item) {
        croak "missing required parameters";
    }

    if (ref $item ne "HASH") {
        croak "item should be a hash reference";
    }

    my $items = $databaseHandles{$objId}->get_collection('items');

    my $selectId;

    if ($item->{_id}) {
        $selectId = {'_id' => $item->{_id}};
    } elsif ($item->{figshareId}) {
        $selectId = {figshareId => $item->{figshareId}};
    } elsif ($item->{dspaceId}) {
        $selectId = {dspaceId => $item->{dspaceId}};
    } elsif ($item->{rssId}) {
        $selectId = {rssId => $item->{rssId}};
    }

    $item = $self->extendItem($item, $selectId);

    my $itemId;

    if ($selectId) {
        $itemId = $items->update(
            $selectId,
            {'$set' => $item},
            {upsert => 1},
        );
    } else {
        $itemId = $items->insert($item)->{value};
    }

    return $itemId;
}

sub extendItem {
    my ($self, $item, $selectId) = @_;

    my $objId = ident $self;

    if (!$item) {
        croak "missing required parameters";
    }

    if (ref $item ne "HASH") {
        croak "item should be a hash reference";
    }

    my $existingItem = {};

    if ($selectId) {
       $existingItem = pop @{$self->getItems($selectId)};
    }

    foreach my $property ('statuses', 'timestamps') {
        if (ref $item->{$property} ne "HASH" && ref $existingItem->{$property} ne "HASH") {
            $item->{$property} = {};
        }
    }

    return $item;
}

sub getTweets {
    my ($self, $parameters) = @_;

    if ($parameters && ref $parameters ne "HASH") {
        croak "parameter must be a hash reference";
    }

    my $objId = ident $self;

    my $tweets = $databaseHandles{$objId}->get_collection('tweetLog');

    my $foundTweets = $tweets->find($parameters || {});

    return [$foundTweets->all()];
}

sub saveTweet {
    my ($self, $tweet) = @_;

    if ($tweet && ref $tweet ne "HASH") {
        croak "tweet must be a hash reference";
    }

    my $objId = ident $self;

    my $tweets = $databaseHandles{$objId}->get_collection('tweetLog');

    my $tweetId = $tweet->{_id};

    $tweet->{timestamp} = DateTime->from_epoch( epoch => time() );

    if ($tweetId) {
        $tweets->update(
            {'_id' => $tweet->{_id}},
            $tweet,
            {upsert => 1},
        );
    } else {
        $tweet = $tweets->insert($tweet)->{value};
    }

    return $tweetId;
}

sub getPosts {
    my ($self, $parameters) = @_;

    if ($parameters && ref $parameters ne "HASH") {
        croak "parameter must be a hash reference";
    }

    my $objId = ident $self;

    my $posts = $databaseHandles{$objId}->get_collection('postLog');

    my $foundPosts = $posts->find($parameters || {});

    return [$foundPosts->all()];
}

sub savePost {
    my ($self, $post) = @_;

    if ($post && ref $post ne "HASH") {
        croak "post must be a hash reference";
    }

    my $objId = ident $self;

    my $posts = $databaseHandles{$objId}->get_collection('postLog');

    my $postId = $post->{_id};

    $post->{timestamp} = DateTime->from_epoch( epoch => time() );

    if ($postId) {
        $posts->update(
            {'_id' => $post->{_id}},
            $post,
            {upsert => 1},
        );
    } else {
        $post = $posts->insert($post)->{value};
    }

    return $postId;
}


1;
