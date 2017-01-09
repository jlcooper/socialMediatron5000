use strict;
use warnings;

package LupinAgent;

use Class::Std;
use Carp;

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

sub harvest {
    my ($self) = @_;
    my $objId = ident $self;


}
1;
