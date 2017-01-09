use strict;
use warnings;

package DspaceAgent;

use Class::Std;
use Carp;
use DspaceAPI;

use base qw( HarvestingAgent );

my %database : ATTR;
my %configuration : ATTR;
my %dspace : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters || !$parameters->{database} || !$parameters->{configuration}) {
        croak "missing required parameters";
    }

    if (!$parameters->{configuration}->{oaipmhBaseUrl} || !$parameters->{configuration}->{publishedSince}) {
        croak "missing required configuration settings";
    }

    $database{$objId} = $parameters->{database};
    $configuration{$objId} = $parameters->{configuration};

    $dspace{$objId} = DspaceAPI->new({
        oaipmhBaseUrl => $parameters->{configuration}->{oaipmhBaseUrl},
    });
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
    delete $configuration{$objId};
    delete $dspace{$objId};
}

sub harvest {
    my ($self) = @_;
    my $objId = ident $self;

    if (!$self->readyToHarvest()) {
        return;
    }

    my $dspaceOptions = {};

    if ($configuration{$objId}->{publishedSince}) {
        $dspaceOptions->{publishedSince} = $configuration{$objId}->{publishedSince};
    }

    if ($configuration{$objId}->{whiteList}) {
        $dspaceOptions->{whiteList} = $configuration{$objId}->{whiteList};
    }

    if ($configuration{$objId}->{blackList}) {
        $dspaceOptions->{blackList} = $configuration{$objId}->{blackList};
    }

    if ($configuration{$objId}->{types}) {
        $dspaceOptions->{types} = $configuration{$objId}->{types};
    }

    my $publications = $dspace{$objId}->getPublications($dspaceOptions);

    foreach my $item (@{$publications}) {
        if (!$item->{type}) {
            $item->{type} = [];
        }
        $database{$objId}->saveItem($item);
    }

    #
    # Dspace's oaipmh indices are updated nightly so we want to be a day behind on our
    # publishedSince setting.
    #
    my $aDayAgo = time() - (24 * 60 * 60);
    my (undef, undef, undef, $day, $month, $year) = localtime($aDayAgo);
    $month++;
    $year+=1900;

    $configuration{$objId}->{publishedSince} = sprintf("%04d-%02d-%02d 00:00:00", $year, $month, $day);

    $database{$objId}->saveConfiguration($configuration{$objId});

    $self->finishedHarvesting();
}

1;
