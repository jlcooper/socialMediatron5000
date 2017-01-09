use strict;
use warnings;

package Controller;

use Class::Std;
use Carp;
use Module::Load;

use Data::Dumper;

my %database : ATTR;
my %loadedModules : ATTR;


# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters || !$parameters->{database}) {
        croak "missing required parameters";
    }

    $database{$objId} = $parameters->{database};
    $loadedModules{$objId} = {};
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
    delete $loadedModules{$objId};
}

sub getHarvestingAgents {
    my ($self) = @_;

    my $objId = ident $self;

    my $harvestingAgentConfigurations = $database{$objId}->getActiveConfigurationsWithProperties(['harvester']);

    my $harvestingAgents = createAgents($self, $harvestingAgentConfigurations);

    return $harvestingAgents;
}


sub getPublishingAgents {
    my ($self) = @_;

    my $objId = ident $self;

    my $publishingAgentConfigurations = $database{$objId}->getActiveConfigurationsWithProperties(['publisher']);

    my $publishingAgents = createAgents($self, $publishingAgentConfigurations);

    return $publishingAgents;
}


sub createAgents {
    my ($self, $agentConfigurations) = @_;

    my $objId = ident $self;

    my $agents = [];

    foreach my $configuration (@{$agentConfigurations}) {
        if ($configuration->{agent}) {
            if (!$loadedModules{$objId}->{$configuration->{agent}}) {
               load $configuration->{agent};
               $loadedModules{$objId}->{$configuration->{agent}} = 1;
            }

            push @{$agents}, $configuration->{agent}->new({
                database => $database{$objId},
                configuration => $configuration
            });
        }
    }

    return $agents;
}

1;
