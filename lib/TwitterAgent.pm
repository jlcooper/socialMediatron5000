use strict;
use warnings;

package TwitterAgent;

use Class::Std;

use base qw( PublishingAgent );

use Carp;
use Data::Dumper;
use List::MoreUtils qw(any);
use Net::Twitter;
use Try::Tiny;

use Readonly;

Readonly my $MAX_URL_LENGTH => 30;

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

sub prepareTweets {
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

sub formatTweet {
    my ($self, $parameters) = @_;

    my @tweetComponents;

    my @order;

    if ($parameters->{prepend}) {
        push @order, 'prepend';
    }

    push @order, @{$parameters->{order}};

    my $elementToShortenIndex = 0;
    my $elementToShorten = 0;

    my $tweetLength = 0;

    foreach my $element (@order) {
        if ($element eq $parameters->{shortenToFit}) {
            $elementToShorten = $elementToShortenIndex;
        }

        if (ref $parameters->{$element} eq "ARRAY") {
            push @tweetComponents, join(', ', @{$parameters->{$element}});
            foreach my $parameter (@{$parameters->{$element}}) {
                $tweetLength += parameterLength($parameter) + 2;
            }

            # Correct the tweet length as we'll have added two characters at the end when only one
            # separating character will be used later
            $tweetLength--;
        } else {
            push @tweetComponents, $parameters->{$element};
            $tweetLength += parameterLength($parameters->{$element}) + 1;
        }
        $elementToShortenIndex++;
    }

    # Correc the tweet length as we won't have separating character after the last element.
    $tweetLength--;

    my $tweetText = join(' ', @tweetComponents);

    if ($tweetLength > 140) {
        my $shortenBy = ($tweetLength - 140) + 3;
        $tweetComponents[$elementToShorten] = substr($tweetComponents[$elementToShorten], 0, length($tweetComponents[$elementToShorten]) - $shortenBy) . "...";
        $tweetText = join(' ', @tweetComponents);
    }

    return $tweetText;
}

sub parameterLength {
    my ($parameter) = @_;

    if (length $parameter < $MAX_URL_LENGTH ||
        $parameter !~ m/^https?:\/\//) {

        return length $parameter;
    }

    return $MAX_URL_LENGTH;
}

sub publish {
    my ($self) = @_;

    my $objId = ident $self;

    $self->prepareTweets();

    my $tweetSent = 1;

    if (!$self->sendTweet()) {
        if (!$self->sendICYMITweet()) {
            $tweetSent = 0;
        }
    }

    return $tweetSent;
}


sub sendTweet {
    my ($self) = @_;
    my $objId = ident $self;

    my $items = $database{$objId}->getItemsWithStatusFor({
        agent => $configuration{$objId}->{title},
        status => 'Pending',
        limit => 1,
    });

    my $lastTweeted = $configuration{$objId}->{lastTweeted} || 0;
    my $tweetThreshold = $configuration{$objId}->{tweetThreshold} || 0;

    if (scalar @{$items} && 
       (time() - $lastTweeted) >= $tweetThreshold) {

        my $item = $items->[0];

        my $tweetText = $self->formatTweet({
            order => $configuration{$objId}->{order},
            shortenToFit => $configuration{$objId}->{shortenToFit},
            hashtags => $configuration{$objId}->{hashtags} || [],
            title => $item->{title} || '',
            tags => $item->{tags} || '',
            doi => $item->{doi} ? "https://dx.doi.org/$item->{doi}" : '',
            url => $item->{url} || '',
        });

        if ($configuration{$objId}->{icymi}) {
            $item->{statuses}->{$configuration{$objId}->{title}} = "Pending ICYMI";
        } else {
            $item->{statuses}->{$configuration{$objId}->{title}} = "Done";
        }
        $database{$objId}->saveItem($item);

        $self->makeTweet($tweetText);
        
        $configuration{$objId}->{lastTweeted} = time();
        $database{$objId}->saveConfiguration($configuration{$objId});

        return 1;
    }

    return;
}

sub sendICYMITweet {
    my ($self) = @_;
    my $objId = ident $self;

    my $items = $database{$objId}->getItemsWithStatusFor({
        agent => $configuration{$objId}->{title},
        status => 'Pending ICYMI',
        limit => 1,
    });

    my $lastTweeted = $configuration{$objId}->{lastTweeted} || 0;
    my $tweetThreshold = $configuration{$objId}->{tweetThreshold} || 0;

    if (scalar @{$items} && 
       (time() - $lastTweeted) >= $tweetThreshold) {

        my $item = $items->[0];

        if (time() - $item->{timestamps}->{$configuration{$objId}->{title}} > $configuration{$objId}->{icymiThreshold}) {
            my $tweetText = $self->formatTweet({
                prepend => 'icymi..',
                order => $configuration{$objId}->{order},
                shortenToFit => $configuration{$objId}->{shortenToFit},
                hashtags => $configuration{$objId}->{hashtags} || [],
                title => $item->{title} || '',
                tags => $item->{tags} || '',
                doi => $item->{doi} ? "https://dx.doi.org/$item->{doi}" : '',
                url => $item->{url} || '',
            });

            $item->{statuses}->{$configuration{$objId}->{title}} = "Done";
            $database{$objId}->saveItem($item);

            $self->makeTweet($tweetText);

            $configuration{$objId}->{lastTweeted} = time();
            $database{$objId}->saveConfiguration($configuration{$objId});

            return 1;
        }
    }

    return;
}

sub makeTweet {
    my ($self, $tweet) = @_;

    my $objId = ident $self;

    if ($configuration{$objId}->{consumer_key} && $configuration{$objId}->{consumer_secret} &&
        $configuration{$objId}->{access_token} && $configuration{$objId}->{access_token_secret}) {

        my $twitter = Net::Twitter->new(
            traits              => [qw/API::RESTv1_1/],
            consumer_key        => $configuration{$objId}->{consumer_key},
            consumer_secret     => $configuration{$objId}->{consumer_secret},
            access_token        => $configuration{$objId}->{access_token},
            access_token_secret => $configuration{$objId}->{access_token_secret},
        );

        try {
            my $result = $twitter->update($tweet);
            $self->logTweet($tweet);
        } catch {
            carp "$_";
            $self->logTweet("FAILED: $_ [$tweet]");
        }
    }

    return;
}

sub logTweet {
    my ($self, $tweet) = @_;

    my $objId = ident $self;

    $database{$objId}->saveTweet({
        tweet => $tweet,
        agent => $configuration{$objId}->{title},
    });
}
1;
