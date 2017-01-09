use strict;
use warnings;

package Configuration;

use Class::Std;
use Carp;
use Data::Dumper;

my %database : ATTR;
my %configurations : ATTR;
my %configurationIds : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters->{database}) {
        croak "missing required parameters";
    }

    $database{$objId} = $parameters->{database};

    if ($parameters->{configurationId}) {
        $configurationIds{$objId} = $parameters->{configurationId};
        $configurations{$objId} = $database{$objId}->getConfiguration($parameters->{configurationId}); 
    }
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $database{$objId};
    delete $configurations{$objId};
    delete $configurationIds{$objId};
}

sub getAttribute {
    my ($self, $attribute) = @_;

    my $objId = ident $self;

    if (!$attribute) {
        croak "missing required parameter"
    }

    return $configurations{$objId}->{$attribute};
}

sub setAttribute {
    my ($self, $attributes) = @_;

    my $objId = ident $self;

    if (!$attributes) {
        croak "missing required parameter"
    }

    foreach my $attribute (keys %{$attributes}) {
        $configurations{$objId}->{$attribute} = $attributes->{$attribute};
    }

    return undef;
}

sub save {
    my ($self) = @_;

    my $objId = ident $self;

    $configurationIds{$objId} = $database{$objId}->saveConfiguration({
        configurationId => $configurationIds{$objId},
        configuration => $configurations{$objId},   
    }); 

    return $configurationIds{$objId};
}

1;
