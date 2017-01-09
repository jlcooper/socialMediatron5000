use strict;
use warnings;

package Fake::Database;

use Class::Std;
use Carp;
use MongoDB::OID;
use Readonly;
use Data::Dumper;

my %configurations : ATTR;
my %items : ATTR;
my %tweets : ATTR;
my %posts : ATTR;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $objId, $parameters) = @_;

    $configurations{$objId} = {};
    $items{$objId} = {};
    $tweets{$objId} = {};
    $posts{$objId} = {};
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $objId) = @_;

    delete $configurations{$objId};
    delete $items{$objId};
    delete $tweets{$objId};
    delete $posts{$objId};
}


sub getConfiguration {
    my ($self, $configurationId) = @_;

    my $objId = ident $self;

    if (!$configurations{$objId}->{$configurationId}) {
        croak "unknown configuration $configurationId";
    }

    my $configuration = {%{$configurations{$objId}->{$configurationId}}};

    return $configuration;
}


sub getConfigurationsWithProperties {
    my ($self, $properties) = @_;

    my $objId = ident $self;

    my @allValidConfigurations;

    foreach my $configuration (values %{$configurations{$objId}}) {
        my $valid = 0;

        if ($configuration->{properties}) {
            $valid = 1;

            PROPERTY_CRITERIA:
            foreach my $propertyCriteria (@{$properties}) {
                my $found = 0;
                PROPERTIES:
                foreach my $property (@{$configuration->{properties}}) {
                    if ($propertyCriteria eq $property) {
                        $found = 1;
                        last PROPERTIES;
                    }
                }

                if (!$found) {
                    $valid = 0;
                    last PROPERTY_CRITERIA;
                }
            }
        }

        if ($valid) {
            push @allValidConfigurations, $configuration;
        }        
    }

    return \@allValidConfigurations;
}

sub getActiveConfigurationsWithProperties {
    my ($self, $properties) = @_;

    my $objId = ident $self;

    my @allValidConfigurations;

    foreach my $configuration (values %{$configurations{$objId}}) {
        my $valid = 0;

        if ($configuration->{active} && $configuration->{properties}) {
            $valid = 1;

            PROPERTY_CRITERIA:
            foreach my $propertyCriteria (@{$properties}) {
                my $found = 0;
                PROPERTIES:
                foreach my $property (@{$configuration->{properties}}) {
                    if ($propertyCriteria eq $property) {
                        $found = 1;
                        last PROPERTIES;
                    }
                }

                if (!$found) {
                    $valid = 0;
                    last PROPERTY_CRITERIA;
                }
            }
        }

        if ($valid) {
            push @allValidConfigurations, $configuration;
        }        
    }

    return \@allValidConfigurations;
}


sub saveConfiguration {
    my ($self, $configuration) = @_;

    my $objId = ident $self;

    $configuration->{_id} ||= MongoDB::OID->new();

    $configurations{$objId}->{$configuration->{_id}} = $configuration;

    return $configuration->{_id};
}

sub updateConfigurationField {
    my ($self, $configurationId, $field, $newValue) =@_;

    my $objId = ident $self;

    $configurations{$objId}->{$configurationId}->{$field} = $newValue;

    return $configurationId;
}

sub getItems {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    my @foundItems;

    foreach my $itemId (keys %{$items{$objId}}) {
        push @foundItems, $items{$objId}->{$itemId};
    }

    return \@foundItems;
}


sub getItemsWithoutStatusFor {
    my ($self, $agent) = @_;

    if (!$agent) {
        croak "missing required parameters";
    }

    my $objId = ident $self;

    my @itemsWithoutAgentStatus;

    foreach my $item (values %{$items{$objId}}) {
        if (!$item->{statuses}->{$agent}) {
            push @itemsWithoutAgentStatus, $item;
        }
    }

    return \@itemsWithoutAgentStatus;
}

sub getItemsWithStatusFor {
    my ($self, $parameters) = @_;

    if (!$parameters) {
        croak "missing required parameters";
    }

    if (ref $parameters ne "HASH") {
        croak "parameter mush be a hash reference"
    }

    my $objId = ident $self;

    my @itemsWithAgentStatus;

    foreach my $item (values %{$items{$objId}}) {
        if ($item->{statuses}->{$parameters->{agent}} && $item->{statuses}->{$parameters->{agent}} eq $parameters->{status}) {
            push @itemsWithAgentStatus, $item;
        }
    }

    if ($parameters->{limit} && scalar @itemsWithAgentStatus) {
        @itemsWithAgentStatus = sort {$a->{timestamps}->{$parameters->{agent}} <=> $b->{timestamps}->{$parameters->{agent}}} @itemsWithAgentStatus;
        @itemsWithAgentStatus = @itemsWithAgentStatus[0 .. $parameters->{limit}-1];       
    }

    return \@itemsWithAgentStatus;
}

sub dumpItems {
    my ($self) = @_;
    my $objId = ident $self;

    warn Dumper($items{$objId});
}



sub saveItem {
    my ($self, $item) = @_;

    my $objId = ident $self;

    $item->{_id} ||= MongoDB::OID->new();

    $item = $self->extendItem($item);

    $items{$objId}->{$item->{_id}} = $item;

    return $item->{_id};
}

sub extendItem {
    my ($self, $item) = @_;

    my $objId = ident $self;

    if (!$item) {
        croak "missing required parameters";
    }

    if (ref $item ne "HASH") {
        croak "item should be a hash reference";
    }

    foreach my $property ('statuses', 'timestamps') {
        if (ref $item->{$property} ne "HASH") {
            $item->{$property} = {};
        }
    }

    return $item;
}

sub getTweets {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    my @tweets;
    if ($parameters) {
        if ($parameters->{timestamp}) {
            if ($parameters->{timestamp}->{gte}) {
                @tweets = grep {$_->{timestamp}->epoch() >= $parameters->{timestamp}->{gte}->epoch()} values %{$tweets{$objId}};
            }
        }
    } else {
        @tweets = values %{$tweets{$objId}};
    }

    return \@tweets;
}


sub saveTweet {
    my ($self, $tweet) = @_;

    my $objId = ident $self;

    $tweet->{_id} ||= MongoDB::OID->new();

    $tweets{$objId}->{$tweet->{_id}}=$tweet;

    return $tweet->{_id};
}

sub getPosts {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    my @posts;
    if ($parameters) {
        if ($parameters->{timestamp}) {
            if ($parameters->{timestamp}->{gte}) {
                @posts = grep {$_->{timestamp}->epoch() >= $parameters->{timestamp}->{gte}->epoch()} values %{$posts{$objId}};
            }
        }
    } else {
        @posts = values %{$posts{$objId}};
    }

    return \@posts;
}


sub savePost {
    my ($self, $post) = @_;

    my $objId = ident $self;

    $post->{_id} ||= MongoDB::OID->new();

    $posts{$objId}->{$post->{_id}}=$post;

    return $post->{_id};
}



1;
