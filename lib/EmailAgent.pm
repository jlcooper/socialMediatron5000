use strict;
use warnings;

package EmailAgent;

use Class::Std;

use base qw( PublishingAgent );

use Carp;
use Data::Dumper;
use List::MoreUtils qw(any);
use Try::Tiny;

use Readonly;

Readonly my $SENDMAIL => "/usr/sbin/sendmail";

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

sub prepareEmails {
    my ($self) = @_;

    my $objId = ident $self;

    my $items = $database{$objId}->getItemsWithoutStatusFor($configuration{$objId}->{title});

    foreach my $item (@{$items}) {
        if ($self->validItemType($item) &&
            $self->validItemSource($item) &&
            $self->validItemSet($item)
        ) {
            $item->{statuses}->{$configuration{$objId}->{title}} = "Pending";
        } else {
            $item->{statuses}->{$configuration{$objId}->{title}} = "Done"; 
        }
        $item->{timestamps}->{$configuration{$objId}->{title}} = time();

        $database{$objId}->saveItem($item);
    }

    return;
}

sub formatItem {
    my ($self, $parameters) = @_;

    my @itemComponents;

    my @order;

    if ($parameters->{prepend}) {
        push @order, 'prepend';
    }

    push @order, @{$parameters->{order}};

    foreach my $element (@order) {
        if (ref $parameters->{$element} eq "ARRAY") {
            push @itemComponents, join(', ', @{$parameters->{$element}});
        } else {
            push @itemComponents, $parameters->{$element};
        }
    }

    my $itemText = join(' ', @itemComponents);

    return $itemText;
}



sub sendEmailDigest {
    my ($self) = @_;

    my $objId = ident $self;

    my $items = $database{$objId}->getItemsWithStatusFor({
        agent => $configuration{$objId}->{title},
        status => 'Pending',
    });

    my $lastEmailed = $configuration{$objId}->{lastEmailed} || 0;
    my $emailThreshold = $configuration{$objId}->{emailThreshold} || 0;

    if (scalar @{$items} && 
       (time() - $lastEmailed) >= $emailThreshold) {

        my $emailBody = $configuration{$objId}->{emailHeader} || '';

        foreach my $item (@{$items}) {
            $emailBody .= $self->formatItem({
                order => $configuration{$objId}->{order},
                title => $item->{title} || '',
                tags => $item->{tags} || '',
                doi => $item->{doi} ? "https://dx.doi.org/$item->{doi}" : '',
                url => $item->{url} || '',
                prepend => "\t* ",
            }) . "\n\n";

            $item->{statuses}->{$configuration{$objId}->{title}} = "Done";
            $database{$objId}->saveItem($item);
        }

        $emailBody .= $configuration{$objId}->{emailFooter} || '';

        $self->sendEmail($emailBody);
        
        $configuration{$objId}->{lastEmailed} = time();
        $database{$objId}->saveConfiguration($configuration{$objId});

        return 1;
    }

    return;
}


sub publish {
    my ($self) = @_;

    my $objId = ident $self;

    $self->prepareEmails();

    my $emailSent = $self->sendEmailDigest() || 0;

    return $emailSent;
}


sub sendEmail {
    my ($self, $emailBody) = @_;

    my $objId = ident $self;

    open MTA, "|$SENDMAIL -t" or die "unable to open sendmail";

    print MTA<<EOEMAIL;
from: $configuration{$objId}->{emailFrom}
to: $configuration{$objId}->{emailTo}
subject: $configuration{$objId}->{emailSubject}

$emailBody
EOEMAIL

    close MTA;
}

1;
