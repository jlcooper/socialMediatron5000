use strict;
use warnings;

package FacebookAgent;

use Class::Std;

use base qw( PublishingAgent );

use Carp;
use List::MoreUtils qw(any);
use Data::Dumper;
use Try::Tiny;
use Facebook::OpenGraph;

use Readonly;

use Settings qw(%FACEBOOK_SETTINGS);

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

sub preparePosts {
    my ($self) = @_;

    my $objId = ident $self;

    my $items = $database{$objId}->getItemsWithoutStatusFor($configuration{$objId}->{title});

    foreach my $item (@{$items}) {
        if ($self->validItemType($item) && $self->validItemSource($item)) {
            $item->{statuses}->{$configuration{$objId}->{title}} = "Pending";
        } else {
            $item->{statuses}->{$configuration{$objId}->{title}} = "Done"; 
        }
        $item->{timestamps}->{$configuration{$objId}->{title}} = time();

        $database{$objId}->saveItem($item);
    }

    return;
}

sub formatPostFields {
    my ($self, $parameters) = @_;

    my $objId = ident $self;

    my $fields = {};
    my @message;

    foreach my $element (@{$configuration{$objId}->{order}}) {
        if (ref $parameters->{$element} eq "ARRAY") {
            push @message, join(', ', @{$parameters->{$element}});
        } elsif ($parameters->{$element}) {
            push @message, $parameters->{$element};
        }
    }

    if (!scalar @message) {
        croak "no fields to post";
    }

    @message = map {
        my $part = $_;

        $part =~ s/\n//gs;

        $part =~ s/<\/?(p|li|h\d+).*?>/\n/gsi;

        $part
    } @message;

    $fields->{message} = join("\n\n", @message);
    
    $fields->{message} =~ s/<.*?>//gs;

    if ($parameters->{$configuration{$objId}->{link}}) {
        $fields->{link} = $parameters->{$configuration{$objId}->{link}};
    }

    return $fields;
}


sub publish {
    my ($self) = @_;

    my $objId = ident $self;

    $self->preparePosts();

    my $postSent = 1;

    if (!$self->sendPost()) {
        $postSent = 0;
    }

    return $postSent;
}


sub sendPost {
    my ($self) = @_;
    my $objId = ident $self;

    my $items = $database{$objId}->getItemsWithStatusFor({
        agent => $configuration{$objId}->{title},
        status => 'Pending',
        limit => 1,
    });

    my $lastPosted = $configuration{$objId}->{lastPosted} || 0;
    my $postThreshold = $configuration{$objId}->{postThreshold} || 0;

    if (scalar @{$items} && 
       (time() - $lastPosted) >= $postThreshold) {

        my $item = $items->[0];

        my $postFields = $self->formatPostFields($item);

        $item->{statuses}->{$configuration{$objId}->{title}} = "Done";

        $database{$objId}->saveItem($item);

        $self->makePost($postFields);
        
        $configuration{$objId}->{lastPosted} = time();
        $database{$objId}->saveConfiguration($configuration{$objId});

        return 1;
    }

    return;
}

sub makePost {
    my ($self, $post) = @_;

    my $objId = ident $self;

    if ($configuration{$objId}->{accessToken} && $configuration{$objId}->{pageId}) {

        my $facebook = Facebook::OpenGraph->new({
            app_id => $FACEBOOK_SETTINGS{appId},
            secret => $FACEBOOK_SETTINGS{secret},
            namespace => $FACEBOOK_SETTINGS{namespace},
        });

        $facebook->set_access_token($configuration{$objId}->{accessToken});

        if($configuration{$objId}->{imageUrl}) {
            $post->{picture} = $configuration{$objId}->{imageUrl};
        }

        try {
            my $result = $facebook->post(sprintf("%d/feed", $configuration{$objId}->{pageId}), $post);

            $self->logPost($post);
        } catch {
            carp "$_";
            $self->logPost("FAILED: $_ [$post]");
        }
    }

    return;
}

sub logPost {
    my ($self, $post) = @_;

    my $objId = ident $self;

    $database{$objId}->savePost({
        post => $post,
        agent => $configuration{$objId}->{title},
    });
}
1;
