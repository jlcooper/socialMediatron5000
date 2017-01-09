use strict;
use warnings;

package TweetLog;

use Class::Std;
use Carp;
use DateTime;

my %database : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters->{database}) {
        croak "missing required parameters";
    }

    $database{$objId} = $parameters->{database};
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
}

sub saveTweet {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    if (!$parameters->{tweet} || !$parameters->{agent}) {
        croak "missing required parameters";
    }

    $database{$objId}->saveTweet($parameters);
}

sub getTweetsSince {
    my ($self, $timestamp) = @_;

    my $objId = ident $self;

    if (!$timestamp) {
        croak "missing required parameters";
    }

    if ($timestamp !~ m/^\d+$/) {
        croak "timestamp must be an epoch";
    }

    return $database{$objId}->getTweets({
        timestamp => {
            gte => DateTime->from_epoch(epoch => $timestamp),
        },
    });
}

1;
