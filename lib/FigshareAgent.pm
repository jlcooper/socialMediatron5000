use strict;
use warnings;

package FigshareAgent;

use Class::Std;
use Carp;
use FigshareAPI;

use base qw( HarvestingAgent );

my %database : ATTR;
my %configuration : ATTR;
my %figshare : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters || !$parameters->{database} || !$parameters->{configuration}) {
        croak "missing required parameters";
    }

    if (!$parameters->{configuration}->{institutionId} || !$parameters->{configuration}->{apiUrl} || 
        !$parameters->{configuration}->{publishedSince}) {
        croak "missing required configuration settings";
    }

    $database{$objId} = $parameters->{database};
    $configuration{$objId} = $parameters->{configuration};

    $figshare{$objId} = FigshareAPI->new({
        apiUrl => $parameters->{configuration}->{apiUrl},
        institutionId => $parameters->{configuration}->{institutionId},
    });
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
    delete $configuration{$objId};
    delete $figshare{$objId};
}

sub harvest {
    my ($self) = @_;
    my $objId = ident $self;

    if (!$self->readyToHarvest()) {
        return;
    }

    my $datasets = $figshare{$objId}->getDatasets({'publishedSince' => $configuration{$objId}->{publishedSince}});

    foreach my $item (@{$datasets}) {
        if (!$item->{type}) {
            $item->{type} = [];
        }
        if ($item->{id}) {
            $item->{figshareId} = $item->{id};
            delete $item->{id};
        }
        push @{$item->{type}}, 'dataset';
        $database{$objId}->saveItem($item);
    }

    my (undef, undef, undef, $day, $month, $year) = localtime(time());
    $month++;
    $year+=1900;

    $configuration{$objId}->{publishedSince} = sprintf("%04d-%02d-%02d", $year, $month, $day);

    $database{$objId}->saveConfiguration($configuration{$objId});

    $self->finishedHarvesting();
}

1;
