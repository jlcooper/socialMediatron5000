use strict;

use DspaceAPI;

#
# Mock out the actual routines that call Elements as we don't want to
# call it in our testing
#

package DspaceAPI;

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



package DspaceAPI::Test;

use base 'Test::Class';

use Test::More;
use Test::Exception;
use Test::Deep;
use Perl6::Slurp;
use Readonly;

use Data::TestDspaceAPI qw(
    $PUBLICATIONS_SINCE_1 $PUBLICATIONS_SINCE_TERMINATOR

    $SETS_1 $SETS_2 $SETS_3 $SETS_4

    $SET_SPEC_TO_NAME_MAPPING

    $PUBLICATION_1 $PUBLICATION_2 $PUBLICATION_3 $PUBLICATION_4
    $PUBLICATION_5 $PUBLICATION_6 $PUBLICATION_7
);


Readonly my $OAIPMH_BASE_URL => "https://dspace.lboro.ac.uk/dspace-oai/request";

Readonly my $PUBLISHED_SINCE => '2016-01-03 00:00:00';
Readonly my $PUBLISHED_SINCE_URI_COMPONENT => '2016-01-03%2000%3A00%3A00';

my $dspaceAPI;

sub setup : Test(setup) {
    $dspaceAPI = DspaceAPI->new({
        oaipmhBaseUrl => $OAIPMH_BASE_URL,
    });

    $dspaceAPI->clearResponses();
    $dspaceAPI->clearApiCalls();

    $dspaceAPI->pushResponse({
        url => "$OAIPMH_BASE_URL?verb=ListSets",
        status => $SETS_1->{status},
        response => $SETS_1->{response}
    });
    
    $dspaceAPI->pushResponse({
        url => "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
        status => $SETS_2->{status},
        response => $SETS_2->{response}
    });
    
    $dspaceAPI->pushResponse({
        url => "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
        status => $SETS_3->{status},
        response => $SETS_3->{response}
    });
    
    $dspaceAPI->pushResponse({
        url => "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",
        status => $SETS_4->{status},
        response => $SETS_4->{response}
    });
 
    $dspaceAPI->pushResponse({
        url => "$OAIPMH_BASE_URL?verb=ListRecords&metadataPrefix=oai_dc&from=$PUBLISHED_SINCE_URI_COMPONENT",
        status => $PUBLICATIONS_SINCE_1->{status},
        response => $PUBLICATIONS_SINCE_1->{response}
    });
 
    $dspaceAPI->pushResponse({
        url => "$OAIPMH_BASE_URL?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        status => $PUBLICATIONS_SINCE_TERMINATOR->{status},
        response => $PUBLICATIONS_SINCE_TERMINATOR->{response},
    });
 
}

sub _new : Test(3) {
    throws_ok {DspaceAPI->new()} qr/missing OAIPMH connection details/;

    isa_ok($dspaceAPI, 'DspaceAPI');

    cmp_deeply($dspaceAPI->getApiDetails(), {
            oaipmhBaseUrl => $OAIPMH_BASE_URL,
        },
        'OAIPMH Details should match what we provided as object creation.'
    );
}

sub getPublications : Test(4) {
    throws_ok {$dspaceAPI->getPublications()} qr/missing required parameters/;
    throws_ok {$dspaceAPI->getPublications('asdf')} qr/parameters should be a hash reference/;
 
    my $publications = $dspaceAPI->getPublications({'publishedSince' => $PUBLISHED_SINCE});
 
    cmp_deeply(
        $dspaceAPI->getApiCalls(),
        bag(
            "$OAIPMH_BASE_URL?verb=ListSets",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$OAIPMH_BASE_URL?verb=ListRecords&metadataPrefix=oai_dc&from=$PUBLISHED_SINCE_URI_COMPONENT",
            "$OAIPMH_BASE_URL?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case getPublications should make two calls to via OAIPMH to Dspace"
    );

    cmp_deeply(
        $publications,
        bag(
            $PUBLICATION_1, $PUBLICATION_2, $PUBLICATION_3, $PUBLICATION_4,
            $PUBLICATION_5, $PUBLICATION_6, $PUBLICATION_7
        ),
        'Getting publication since should return our seven test publications'
    );
}

sub getPublicationsWithWhiteList : Test(4) {
    throws_ok {$dspaceAPI->getPublications()} qr/missing required parameters/;
    throws_ok {$dspaceAPI->getPublications('asdf')} qr/parameters should be a hash reference/;
 
    my $publications = $dspaceAPI->getPublications({
        publishedSince => $PUBLISHED_SINCE,
        whiteList => '^(Pre-Prints \(Physics\)|Published Articles \(Physics\))$',
    });
 
    cmp_deeply(
        $dspaceAPI->getApiCalls(),
        bag(
            "$OAIPMH_BASE_URL?verb=ListSets",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$OAIPMH_BASE_URL?verb=ListRecords&metadataPrefix=oai_dc&from=$PUBLISHED_SINCE_URI_COMPONENT",
            "$OAIPMH_BASE_URL?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case getPublications should make 6 calls to via OAIPMH to Dspace"
    );

    cmp_deeply(
        $publications,
        bag(
            $PUBLICATION_1, $PUBLICATION_2, $PUBLICATION_3
        ),
        'Getting publication since should return our three matching test publications'
    );
}


sub getPublicationsWithBlackList : Test(4) {
    throws_ok {$dspaceAPI->getPublications()} qr/missing required parameters/;
    throws_ok {$dspaceAPI->getPublications('asdf')} qr/parameters should be a hash reference/;

    my $publications = $dspaceAPI->getPublications({
        publishedSince => $PUBLISHED_SINCE,
        blackList => 'Closed',
    });
 
    cmp_deeply(
        $dspaceAPI->getApiCalls(),
        bag(
            "$OAIPMH_BASE_URL?verb=ListSets",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$OAIPMH_BASE_URL?verb=ListRecords&metadataPrefix=oai_dc&from=$PUBLISHED_SINCE_URI_COMPONENT",
            "$OAIPMH_BASE_URL?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case getPublications should make 6 calls to via OAIPMH to Dspace"
    );

    cmp_deeply(
        $publications,
        bag(
            $PUBLICATION_1, $PUBLICATION_2, $PUBLICATION_3, $PUBLICATION_4,
            $PUBLICATION_5,
        ),
        'Getting publication since should return our five matching test publications'
    );
}


sub getPublicationsWithTypes : Test(4) {
    throws_ok {$dspaceAPI->getPublications()} qr/missing required parameters/;
    throws_ok {$dspaceAPI->getPublications('asdf')} qr/parameters should be a hash reference/;

    my $publications = $dspaceAPI->getPublications({
        publishedSince => $PUBLISHED_SINCE,
        types => [
            'Article',
            'Conference Contribution',
        ],
    });
 
    cmp_deeply(
        $dspaceAPI->getApiCalls(),
        bag(
            "$OAIPMH_BASE_URL?verb=ListSets",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",

            "$OAIPMH_BASE_URL?verb=ListRecords&metadataPrefix=oai_dc&from=$PUBLISHED_SINCE_URI_COMPONENT",
            "$OAIPMH_BASE_URL?verb=ListRecords&resumptionToken=MToxMDB8Mjp8MzoyMDE2LTAxLTAzVDAwOjAwOjAwWnw0Onw1Om9haV9kYw==",
        ),
        "In this case getPublications should make two calls to via OAIPMH to Dspace"
    );

    cmp_deeply(
        $publications,
        bag(
            $PUBLICATION_2, $PUBLICATION_4, $PUBLICATION_5, $PUBLICATION_6,
            $PUBLICATION_7,
        ),
        'Getting publication since should return our five matching test publications'
    );
}


sub getSetSpecToNameMapping : Test(2) {
    my $setSpecToName = $dspaceAPI->getSetSpecToNameMapping();
 
    cmp_deeply(
        $dspaceAPI->getApiCalls(),
        bag(
            "$OAIPMH_BASE_URL?verb=ListSets",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToxMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MToyMDB8Mjp8Mzp8NDp8NTo=",
            "$OAIPMH_BASE_URL?verb=ListSets&resumptionToken=MTozMDB8Mjp8Mzp8NDp8NTo=",
        ),
        "In this case getPublications should make four calls to via OAIPMH to Dspace"
    );

    cmp_deeply(
        $setSpecToName,
        $SET_SPEC_TO_NAME_MAPPING,
        "API setSpecToName mapping should match what we expect."
    );
}

1;
