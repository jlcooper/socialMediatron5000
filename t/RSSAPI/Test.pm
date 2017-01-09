use strict;

use RSSAPI;

#
# Mock out the actual routines that call Elements as we don't want to
# call it in our testing
#

package RSSAPI;

my %callResponse;
my $apiCalls = [];

sub pushResponse {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    $callResponse{$parameters->{url}} = {
        status => $parameters->{status},
        response => $parameters->{response},
    };
}


sub callAPI {
    my ($self, $apiUrl) = @_;

    my $objId = ident $self;

    push @{$apiCalls}, $apiUrl;

    my $response = $callResponse{$apiUrl};

    if (!$response) {
        croak "unknown URL called - $apiUrl";
    }

    return $response;
}

sub clearResponses {
    my ($self) = @_;

    %callResponse = ();
}

sub getApiCalls {
    my ($self) = @_;

    return $apiCalls;
}

sub clearApiCalls {
    my ($self) = @_;

    $apiCalls = [];
}



package RSSAPI::Test;

use base 'Test::Class';

use Test::More;
use Test::Exception;
use Test::Deep;
use Perl6::Slurp;
use Readonly;

use Data::TestRSSAPI qw(
    $RSS_FEED_1

    $ITEM_1  $ITEM_2  $ITEM_3  $ITEM_4  $ITEM_5
    $ITEM_6  $ITEM_7  $ITEM_8  $ITEM_9  $ITEM_10
    $ITEM_11 $ITEM_12 $ITEM_13 $ITEM_14 $ITEM_15
    $ITEM_16

    $HARVESTED_ITEM_1  $HARVESTED_ITEM_2  $HARVESTED_ITEM_3  $HARVESTED_ITEM_4
    $HARVESTED_ITEM_5  $HARVESTED_ITEM_6  $HARVESTED_ITEM_7  $HARVESTED_ITEM_8
    $HARVESTED_ITEM_9  $HARVESTED_ITEM_10 $HARVESTED_ITEM_11 $HARVESTED_ITEM_12
    $HARVESTED_ITEM_13  $HARVESTED_ITEM_14 $HARVESTED_ITEM_15 $HARVESTED_ITEM_16
);

my $rssAPI;

sub setup : Test(setup) {
    $rssAPI = RSSAPI->new({
        rssUrl => $RSS_FEED_1->{url},
    });

    $rssAPI->clearResponses();
    $rssAPI->clearApiCalls();

    $rssAPI->pushResponse({
        url => $RSS_FEED_1->{url},
        status => $RSS_FEED_1->{status},
        response => $RSS_FEED_1->{response},
    });
}

sub _new : Test(2) {
    isa_ok($rssAPI, 'RSSAPI');

    cmp_deeply($rssAPI->getApiDetails(), {
            rssUrl => $RSS_FEED_1->{url},
        },
        'RSS API Details should match what we provided as object creation.'
    );
}

sub getItems : Test(3) {
    my $items = $rssAPI->getItems();
 
    cmp_deeply(
        $rssAPI->getApiCalls(),
        bag(
            $RSS_FEED_1->{url},
        ),
        "In this case getItems should make one calls to our Feed's url"
    );

    my $rssIdsAdded = 1;
    foreach my $item (@{$items}) {
        if ($item->{rssId}) {
            delete $item->{rssId};
        } else {
            $rssIdsAdded = 0;
        }
    }

    ok($rssIdsAdded, "rssId's should be added to the items");

    cmp_deeply(
        $items,
        bag(
            $ITEM_1,  $ITEM_2,  $ITEM_3,  $ITEM_4,
            $ITEM_5,  $ITEM_6,  $ITEM_7,  $ITEM_8,
            $ITEM_9,  $ITEM_10, $ITEM_11, $ITEM_12,
            $ITEM_13, $ITEM_14, $ITEM_15, $ITEM_16,
        ),
        'getItems should return our ten test items'
    );
}

1;
