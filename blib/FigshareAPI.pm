
package FigshareAPI;

use strict;
use warnings;

use Class::Std;
use Carp;
use Data::Dumper;

use JSON;
use LWP::Simple;

my %apiUrl : ATTR;
my %institutionId : ATTR;

sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters->{apiUrl} || !$parameters->{institutionId}) {
        croak "missing API connection details";
    }

    $apiUrl{$objId} = $parameters->{apiUrl};
    $institutionId{$objId} = $parameters->{institutionId};
}

sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $apiUrl{$objId};
}

sub getApiDetails {
    my ($self) = @_;

    my $objId = ident $self;

    return {
        apiUrl => $apiUrl{$objId},
        institutionId => $institutionId{$objId}
    };
}

sub getDatasets {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    if (!$parameters) {
        croak "missing required parameters";
    }

    if (ref $parameters ne "HASH") {
        croak "parameters should be a hash reference";
    }

    my @datasets;

    my $apiUrl = "$apiUrl{$objId}/articles?";

    my @urlParameters = ("institution=$institutionId{$objId}");

    if ($parameters->{publishedSince}) {
        push @urlParameters, "published_since=$parameters->{publishedSince}";
    }

    $apiUrl .= join('&', @urlParameters);

    my $page = 1;

    API_CALL:
    while (1) {
        my $response = $self->callAPI("$apiUrl&page=$page");

        if ($response->{status} eq "200") {
            my @responseDatasets = $self->parseAPIResponse($response->{response});
            last API_CALL unless scalar @responseDatasets;

            push @datasets, @responseDatasets;
            $page++;
        }
    }

    @datasets = map {$self->enhanceDataset($_)} @datasets;

    return \@datasets;
}

sub parseAPIResponse {
    my ($self, $response) = @_;

    my @datasets;

    my $foundDatasets = decode_json($response);

    foreach my $dataset (@{$foundDatasets}) {
        push @datasets, {
            url => $dataset->{url} || '',
            doi => $dataset->{doi} || '',
            id => $dataset->{id} || '',
            publishedDate => $dataset->{published_date} || '',
            title => $dataset->{title} || '',
        };
    }

    return @datasets;
}

sub enhanceDataset {
    my ($self, $dataset) = @_;

    my $response = $self->callAPI($dataset->{url});

    if ($response->{status} eq "200") {
        my $metadata = decode_json($response->{response});

        if ($metadata->{tags}) {
            $dataset->{tags} = $metadata->{tags};
        }

        if ($metadata->{categories}) {
            if (!$dataset->{categories}) {
                $dataset->{categories} = [];
            }

            foreach my $category (@{$metadata->{categories}}) {
                push @{$dataset->{categories}}, $category->{title};
            }
        }

        if ($metadata->{is_embargoed} ||
            $metadata->{is_confidential} ||
            !$metadata->{files} ||
            ! scalar @{$metadata->{files}}) {

            return ();
        }
    }

    return $dataset;
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
