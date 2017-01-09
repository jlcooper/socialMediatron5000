
package RSSAPI;

use strict;
use warnings;

use Class::Std;
use Carp;
use Data::Dumper;
use URI::Escape;
use DateTime::Format::DateParse;
use HTML::Entities;

use LWP::Simple;
use XML::Simple;

my %rssUrl : ATTR;


sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters->{rssUrl}) {
        croak "missing RSS Feed Url";
    }

    $rssUrl{$objId} = $parameters->{rssUrl};
}


sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $rssUrl{$objId};
}


sub getApiDetails {
    my ($self) = @_;

    my $objId = ident $self;

    return {
        rssUrl => $rssUrl{$objId},
    };
}


sub getItems {
    my ($self, $parameters) = @_;

    my $objId = ident $self;
 
    my @items;

    my $response = $self->callAPI($rssUrl{$objId});

    if ($response->{status} eq "200") {
        my $rssFeed = XMLin($response->{response}, ForceArray => 1);

        use Data::Dumper;

        foreach my $channel (@{$rssFeed->{channel}}) {
            foreach my $item (@{$channel->{item}}) {
                if ($item->{link} && ref $item->{link}->[0] ne "HASH") {
                    $item->{url} = $item->{link}->[0];
                    delete $item->{link};
                }

                if ($item->{pubDate} && ref $item->{pubDate}) {
                    my $publishedDate = DateTime::Format::DateParse->parse_datetime($item->{pubDate}->[0]);
                    $item->{publishedDate} = $publishedDate->datetime();
                    delete $item->{pubDate};

                    $item->{rssId} = $rssUrl{$objId} . "#" .$publishedDate->epoch();
                }

                foreach my $field ('title', 'description') {
                    if ($item->{$field}) {
                        if (ref $item->{$field}->[0] ne "HASH") {
                            $item->{$field} = decode_entities($item->{$field}->[0]);
                        } else {
                            $item->{$field} = '';
                        }
                    }
                }
                push @items, $item;
            }
        }
    }

    return \@items;
}

 
sub callAPI {
    my ($self, $apiUrl) = @_;

    my $objId = ident $self;

    my $response = get($apiUrl);

    if (!$response) {
        croak "error getting '$apiUrl'";
    }

    return {
        status => 200,
        response => $response,
    };
}
 

1;
