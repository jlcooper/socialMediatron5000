
package DspaceAPI;

use strict;
use warnings;

use Class::Std;
use Carp;
use Data::Dumper;
use URI::Escape;

use LWP::Simple;
use XML::Simple;

use Settings qw($DSPACE_IDENTIFIER_MATCH);

my %oaipmhBaseUrl : ATTR;

sub BUILD {
    my ($self, $objId, $parameters) = @_;

    if (!$parameters->{oaipmhBaseUrl}) {
        croak "missing OAIPMH connection details";
    }

    $oaipmhBaseUrl{$objId} = $parameters->{oaipmhBaseUrl};
}


sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $oaipmhBaseUrl{$objId};
}


sub getApiDetails {
    my ($self) = @_;

    my $objId = ident $self;

    return {
        oaipmhBaseUrl => $oaipmhBaseUrl{$objId},
    };
}


sub getPublications {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    if (!$parameters) {
        croak "missing required parameters";
    }

    if (ref $parameters ne "HASH") {
        croak "parameters should be a hash reference";
    }

    my $whiteList = qr/.*/;

    if ($parameters->{whiteList}) {
        $whiteList = qr/$parameters->{whiteList}/i;
    }

    my $blackList = undef;

    if ($parameters->{blackList}) {
        $blackList = qr/$parameters->{blackList}/i;
    }

    my $validTypes = undef;

    if ($parameters->{types}) {
        $validTypes = {};
        foreach my $type (@{$parameters->{types}}) {
            $validTypes->{$type} = 1;
        }
    }

    my $setSpecToName = $self->getSetSpecToNameMapping();

    my @publications;
 
    my @urlParameters = (
        'verb=ListRecords',
        'metadataPrefix=oai_dc',
    );
 
    if ($parameters->{publishedSince}) {
        push @urlParameters, "from=" . uri_escape($parameters->{publishedSince});
    }
 
    my $oaipmhUrl = $oaipmhBaseUrl{$objId} . "?" . join('&', @urlParameters);

    while ($oaipmhUrl) {
        my $response = $self->callAPI($oaipmhUrl);

        $oaipmhUrl = "";

        if ($response->{status} eq "200") {
            my $oaipmhResponse = $self->parseOaipmhResponse($response->{response});

            if ($oaipmhResponse->{resumptionToken} &&
                $oaipmhResponse->{resumptionToken}->[0]->{content}) {

                @urlParameters = (
                    'verb=ListRecords',
                    'resumptionToken=' . $oaipmhResponse->{resumptionToken}->[0]->{content},
                );

                $oaipmhUrl = $oaipmhBaseUrl{$objId} . "?" . join('&', @urlParameters);
            }

            RECORD:
            foreach my $record (@{$oaipmhResponse->{record}}) {
                my $publication = {};
                my $header = $record->{header}->[0];

                if ($header->{identifier}) {
                    $publication->{dspaceId} = $header->{identifier}->[0];
                }

                my $validRecord = 0;

                if ($header->{setSpec}) {
                    $publication->{sets} = [];
                    foreach my $set (@{$header->{setSpec}}) {
                        push @{$publication->{sets}}, {
                            id => $set,
                            name => $setSpecToName->{$set},
                        };

                        if ($setSpecToName->{$set} =~ $whiteList) {
                            $validRecord = 1;
                        }

                        if ($blackList) {
                           next RECORD if $setSpecToName->{$set} =~ $blackList;
                        }
                    }
                }

                next RECORD unless $validRecord;

                my $metadata = $record->{metadata}->[0]->{'oai_dc:dc'}->[0];

                if ($metadata->{'dc:title'}) {
                    $publication->{title} = join(', ', @{$metadata->{'dc:title'}});
                };

                if ($metadata->{'dc:creator'}) {
                    $publication->{authors} = [];
                    foreach my $author (@{$metadata->{'dc:creator'}}) {
                        push @{$publication->{authors}}, $author;
                    }
                }
                
                if ($metadata->{'dc:subject'}) {
                    $publication->{tags} = [];
                    foreach my $tag (@{$metadata->{'dc:subject'}}) {
                        push @{$publication->{tags}}, $tag;
                    }
                }

                if ($metadata->{'dc:description'}) {
                    $publication->{descriptions} = [];
                    foreach my $description (@{$metadata->{'dc:description'}}) {
                        push @{$publication->{descriptions}}, $description;
                    }
                }

                if ($metadata->{'dc:type'}) {
                    $publication->{type} = [];

                    foreach my $type (@{$metadata->{'dc:type'}}) {
                        push @{$publication->{type}}, $type;
                    }
                }

                if ($validTypes) {
                    my $validType = 0;

                    foreach my $type (@{$publication->{type}}) {
                        if ($validTypes->{$type}) {
                            $validType = 1;
                        }
                    }
                    next RECORD unless $validType;
                }

                if ($metadata->{'dc:identifier'}) {
                    foreach my $identifier (@{$metadata->{'dc:identifier'}}) {
                        if ($identifier =~ m/$DSPACE_IDENTIFIER_MATCH/i) {
                            $publication->{url} = $identifier;
                        }

                        if ($identifier =~ m/^10\.\d+\//i) {
                            $publication->{doi} = $identifier;
                        }
                    }
                }

                if ($metadata->{'dc:language'}) {
                    $publication->{language} = $metadata->{'dc:language'}->[0],
                }

                push @publications, $publication;
            }
        }
    }

#    @datasets = map {$self->enhanceDataset($_)} @datasets;

    return \@publications;
}
 
 
sub parseOaipmhResponse {
    my ($self, $response, $dataElement) = @_;

    $dataElement ||= 'ListRecords';

    my $oaipmhResponse = XMLin($response, ForceArray => 1);

    return $oaipmhResponse->{$dataElement}->[0];
}
 

sub getSetSpecToNameMapping {
    my ($self) = @_;

    my $objId = ident $self;

    my %setSpecToName;
 
    my @urlParameters = (
        'verb=ListSets',
    );
 
    my $oaipmhUrl = $oaipmhBaseUrl{$objId} . "?" . join('&', @urlParameters);

    while ($oaipmhUrl) {
        my $response = $self->callAPI($oaipmhUrl);

        $oaipmhUrl = "";

        if ($response->{status} eq "200") {
            my $oaipmhResponse = $self->parseOaipmhResponse($response->{response}, 'ListSets');

            if ($oaipmhResponse->{resumptionToken} &&
                $oaipmhResponse->{resumptionToken}->[0]->{content}) {

                @urlParameters = (
                    'verb=ListSets',
                    'resumptionToken=' . $oaipmhResponse->{resumptionToken}->[0]->{content},
                );

                $oaipmhUrl = $oaipmhBaseUrl{$objId} . "?" . join('&', @urlParameters);
            }

            foreach my $set (@{$oaipmhResponse->{set}}) {
                my $setSpec = $set->{setSpec}->[0];
                my $setName = $set->{setName}->[0];

                $setSpecToName{$setSpec} = $setName;
            }
        }
    }

    return \%setSpecToName;
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
