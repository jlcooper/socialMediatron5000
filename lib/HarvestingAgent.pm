use strict;
use warnings;

package HarvestingAgent;

use Class::Std;
use Carp;
use List::MoreUtils qw(any);
use Data::Dumper;
use Try::Tiny;

use Readonly;

my %database : ATTR;
my %configuration : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters || !$parameters->{database} || !$parameters->{configuration}) {
        croak "missing required parameters";
    }

    $database{$objId} = $parameters->{database};
    $configuration{$objId} = $parameters->{configuration};
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
    delete $configuration{$objId};
}


sub readyToHarvest {
    my ($self) = @_;

    my $objId = ident $self;

    my $harvest = 0;

    my $lastHarvested = $configuration{$objId}->{lastHarvested} || 0;
    my $timeBetweenHarvests = $configuration{$objId}->{timeBetweenHarvests} || 0;

    if (time() - $lastHarvested >= $timeBetweenHarvests) {
        $harvest = 1;
    }

    return $harvest;
}


sub finishedHarvesting {
    my ($self) = @_;

    my $objId = ident $self;

    my $timestamp = time;

    $database{$objId}->updateConfigurationField($configuration{$objId}->{_id}, 'lastHarvested', $timestamp);

    $configuration{$objId}->{lastHarvested} = $timestamp;
}
1;
