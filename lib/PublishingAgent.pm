use strict;
use warnings;

package PublishingAgent;

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

sub validItemType {
    my ($self, $item) = @_;

    my $objId = ident $self;

    my $validType = 0;
    
    if ($item->{type} && $configuration{$objId}->{types}) {
        $validType = any {
            my $itemType = $_;

            any {
                $_ eq $itemType;
            } @{$configuration{$objId}->{types}}
        } @{$item->{type}};
    }

    return $validType;
}

sub validItemSource {
    my ($self, $item) = @_;

    my $objId = ident $self;

    my $validSource = 0;

    if ($configuration{$objId}->{sources} && scalar @{$configuration{$objId}->{sources}}) {
        if ($item->{source}) {
            $validSource = any {
                $_ eq $item->{source};
            } @{$configuration{$objId}->{sources}};
        }
    } else {
        $validSource = 1;
    }

    return $validSource;
}

sub validItemSet {
    my ($self, $item) = @_;

    my $objId = ident $self;

    my $validSet = 0;
    
    if ($configuration{$objId}->{sets} && scalar @{$configuration{$objId}->{sets}}) {
        $validSet = any {
            my $itemSet = $_->{name};

            any {
                $_ eq $itemSet;
            } @{$configuration{$objId}->{sets}}
        } @{$item->{sets}};
    } else {
        $validSet = 1;
    }

    return $validSet;
}

1;
