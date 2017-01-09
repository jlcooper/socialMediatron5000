use strict;
use warnings;

package RSSAgent;

use Class::Std;
use Carp;
use RSSAPI;

use base qw( HarvestingAgent );

my %database : ATTR;
my %configuration : ATTR;
my %rss : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters || !$parameters->{database} || !$parameters->{configuration}) {
        croak "missing required parameters";
    }

    if (!$parameters->{configuration}->{rssUrl}) {
        croak "missing required configuration settings";
    }

    $database{$objId} = $parameters->{database};
    $configuration{$objId} = $parameters->{configuration};

    $rss{$objId} = RSSAPI->new({
         rssUrl => $parameters->{configuration}->{rssUrl},
    });
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
    delete $configuration{$objId};
    delete $rss{$objId};
}

sub harvest {
    my ($self) = @_;
    my $objId = ident $self;

    if (!$self->readyToHarvest()) {
        return;
    }

    my $items = $rss{$objId}->getItems();

    foreach my $item (@{$items}) {
        if (!$item->{type}) {
            $item->{type} = ['Feed Entry'];
        }

        if (!$item->{source}) {
            $item->{source} = $configuration{$objId}->{rssUrl};
        }

        $database{$objId}->saveItem($item);
    }

    $self->finishedHarvesting();
}

1;
