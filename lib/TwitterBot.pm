package TwitterBot;

use strict;
use warnings;

use Readonly;

use lib '/usr/local/projects/socialMediatron5000/lib';

use Database;
use MongoDB::OID;

use Settings qw(
    $DATABASE_HOST $DATABASE_PORT $DATABASE_NAME
);

my $database = Database->new({
    databaseHost => $DATABASE_HOST,
    databasePort => $DATABASE_PORT,
    databaseName => $DATABASE_NAME,
});

sub getHarvestingAgents {
    my $harvestingAgents = $database->getConfigurationsWithProperties(['harvester']);

    return $harvestingAgents;
}

sub getPublishingAgents {
    my $publishingAgents = $database->getConfigurationsWithProperties(['publisher']);

    return $publishingAgents;
}

sub getTweetLog {
    my $tweetlog = $database->getTweets();

    return $tweetlog;
}

sub getPostLog {
    my $postlog = $database->getPosts();

    return $postlog;
}

sub saveConfiguration {
    my (undef, $configuration) = @_;

    if ($configuration->{_id} && ref($configuration->{_id}) ne 'MongoDB::OID') {
        $configuration->{_id} = MongoDB::OID->new($configuration->{_id})
    }

    $database->saveConfiguration($configuration);

    return {
        status => 'saved',
        configuration => $configuration,
    };
}

1;
