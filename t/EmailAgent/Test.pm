use strict;

use EmailAgent;

package EmailAgent;

my @emails;

sub clearEmails {
    @emails = ();
}

sub sendEmail {
    my ($self, $email) = @_;

    push @emails, $email;
}

sub getEmail {
    return pop @emails;
}

use warnings;
package EmailAgent::Test;

use base 'Test::Class';

use Test::More;
use Test::Exception;
use Test::Deep;
use Readonly;
use Data::Dumper;
use Clone qw(clone);

use Fake::Database;

use Data::TestConfigurations qw(
    $TEST_CONFIGURATION_EMAIL_AGENT $TEST_CONFIGURATION_EMAIL_AGENT_WITH_SOURCE
);

use Data::TestItems qw(
    $TEST_ITEM_1 $TEST_ITEM_2 $TEST_ITEM_3 $TEST_ITEM_4 $TEST_ITEM_5 $TEST_ITEM_6 $TEST_ITEM_7
);

my $database;
my $emailAgent;


sub setup : Test(setup) {
    $database = Fake::Database->new();

    $database->saveConfiguration(clone ($TEST_CONFIGURATION_EMAIL_AGENT));

    $emailAgent = EmailAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_EMAIL_AGENT),
    });

    $emailAgent->clearEmails();
}


sub _new : Test(2) {
    throws_ok {EmailAgent->new()} qr/missing required parameters/;
    
    isa_ok($emailAgent, 'EmailAgent');
}


sub prepareNewEmails : Test(1) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_4));

    $emailAgent->prepareEmails();

    my $items = $database->getItems();
    my $validStatuses = 1;

    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this twitter agent');
}

sub formatItem : Test(6) {
    my $emailText = $emailAgent->formatItem({
        order => ['title', 'doi'],
        title => 'title',
        doi => 'http://doi.url.goes.here',
    });

    is($emailText, 'title http://doi.url.goes.here', 'Item should be formatted as specified');

    $emailText = $emailAgent->formatItem({
        order => ['title', 'doi'],
        title => 'title' x 140,
        doi => 'http://doi.url.goes.here',
    });

    is(
        $emailText,
        'titletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitle http://doi.url.goes.here',
        , 'Item should be formatted as specified');

    $emailText = $emailAgent->formatItem({
        order => ['title', 'doi'],
        title => [
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title',
            'title','title','title','title','title','title','title','title','title','title'
        ],
        doi => 'http://doi.url.goes.here',
    });

    is(
        $emailText,
            'title, title, title, title, title, title, title, title, title, title, ' .
            'title, title, title, title, title, title, title, title, title, title, ' .
            'title, title, title, title, title, title, title, title, title, title, ' .
            'title, title, title, title, title, title, title, title, title, title, ' .
            'title, title, title, title, title, title, title, title, title, title ' .
            'http://doi.url.goes.here',

        'Tweet should be formatted as specified'
    );
}



sub sendEmail : Test(6) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_4));
    $database->saveItem(clone($TEST_ITEM_5));
    $database->saveItem(clone($TEST_ITEM_7));

#   my $preTweets = $database->getTweets();

    $emailAgent->sendEmailDigest();

    my $items = $database->getItems();
    my $pendingAfter = 0;
    foreach my $item (@{$items}) {
        if ($item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} &&
            $item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} eq "Pending") {
            $pendingAfter++;
        }
    }

    ok($pendingAfter == 0, 'After sending a digest email we should have no more "Pending" statuses for this agent');

    my $emailText = $emailAgent->getEmail();

    like($emailText,
        qr/^Latest items available:\n/s,
        'email should start with the header text'
    );

    like($emailText,
        qr/\t* Test Title https:\/\/dx.doi.org\/10.17028\/rd.lboro.2005999\n\n/s,
        'email should contain the first test item'
    );

    like($emailText,
        qr/\t* Test Title 5 https:\/\/dx.doi.org\/10.17028\/rd.lboro.2005377\n\n/s,
        'email should contain the second test item'
    );

    like($emailText,
        qr/\t* Test Title 7 https:\/\/dx.doi.org\/10.17028\/rd.lboro.2005379\n\n/s,
        'email should contain the third test item'
    );

    like($emailText,
        qr/\n---\nSocial Mediatron 5000\n$/s,
        'email should finish with the footer'
    );


#    my $postTweets = $database->getTweets();
#
#    is(scalar @{$preTweets}, scalar @{$postTweets} - 1, 'after running we should have another tweet in the tweetLog');
}
 

sub publish : Test(7) {
    $database->saveItem(clone($TEST_ITEM_1));
    $database->saveItem(clone($TEST_ITEM_5));
    $database->saveItem(clone($TEST_ITEM_7));

    $emailAgent->publish();

    my $items = $database->getItems();

    my $validStatuses = 1;
    my $pendingAfterPulishing = 0;
    foreach my $item (@{$items}) {
        if (!$item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} ||
            $item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} !~ m/(?:Pending|Pending ICYMI|Done)/) {
            $validStatuses = 0;
        }

        if ($item->{statuses}->{$TEST_CONFIGURATION_EMAIL_AGENT->{title}} eq "Pending") {
            $pendingAfterPulishing++;
        }
    }

    ok($validStatuses, 'After running all items should have a status for this twitter agent');

    is($pendingAfterPulishing, 0, 'After sending a digest email their should be no more pending items waiting');

    my $emailText = $emailAgent->getEmail();

    like($emailText,
        qr/^Latest items available:\n/s,
        'email should start with the header text'
    );

    like($emailText,
        qr/\t* Test Title https:\/\/dx.doi.org\/10.17028\/rd.lboro.2005999\n\n/s,
        'email should contain the first test item'
    );

    like($emailText,
        qr/\t* Test Title 5 https:\/\/dx.doi.org\/10.17028\/rd.lboro.2005377\n\n/s,
        'email should contain the second test item'
    );

    like($emailText,
        qr/\t* Test Title 7 https:\/\/dx.doi.org\/10.17028\/rd.lboro.2005379\n\n/s,
        'email should contain the third test item'
    );

    like($emailText,
        qr/\n---\nSocial Mediatron 5000\n$/s,
        'email should finish with the footer'
    );
}


sub emailsSetTheLastEmailedTimestamp : Test(2) {
    $database->saveItem(clone($TEST_ITEM_7));

    my $emailTookPlace = $emailAgent->sendEmailDigest();

    is($emailTookPlace, 1, "An email should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_EMAIL_AGENT->{_id});

    ok((time - $configuration->{lastEmailed}) < 10, 'After sending an email the lastEmailed timestamp should be updated');
}


sub tweetThresholdStopsTweeting : Test(4) {
    $database->saveItem(clone($TEST_ITEM_7));
    $database->saveItem(clone($TEST_ITEM_7));

    my $emailTookPlace = $emailAgent->sendEmailDigest();

    is($emailTookPlace, 1, "An email should have taken place.");

    my $configuration = $database->getConfiguration($TEST_CONFIGURATION_EMAIL_AGENT->{_id});
    my $lastEmailed = $configuration->{lastEmailed};

    ok((time - $lastEmailed) < 10, 'After making an email the lastEmailed timestamp should be updated');

    $database->saveItem(clone($TEST_ITEM_7));

    $emailTookPlace = $emailAgent->sendEmailDigest();

    is($emailTookPlace, undef, "An email shouldn't have been sent");

    $configuration = $database->getConfiguration($TEST_CONFIGURATION_EMAIL_AGENT->{_id});

    is($configuration->{lastEmailed}, $lastEmailed, "Emails stopped by the threshold shouldn't update the lastEmailed timestamp");
}


sub validItemType : Test(4) {
    my $item1 = {
        type => ['dataset'],
    };
    my $item2 = {
        type => ['dataset', 'publication'],
    };
    my $item3 = {
        type => ['publication', 'dataset'],
    };
    my $item4 = {
        type => ['publication'],
    };

    ok($emailAgent->validItemType($item1), 'an item with just a type of dataset should be valid');
    ok($emailAgent->validItemType($item2), 'an item with a type of dataset and publication should be valid');
    ok($emailAgent->validItemType($item3), 'an item with a type of publication and dataset should be valid');
    ok(!$emailAgent->validItemType($item4), 'an item with just a type of publication should not be valid');    
}

sub validItemSource : Test(6) {
    my $item1 = {
        source => 'http://www.lboro.ac.uk/',
    };
    my $item2 = {
        source => 'http://www.google.com/',
    };
    my $item3 = {
    };

    ok($emailAgent->validItemSource($item1), 'Sources should not matter when no source has been configured for agent');
    ok($emailAgent->validItemSource($item2), 'Sources should not matter when no source has been configured for agent');
    ok($emailAgent->validItemSource($item3), 'Sources should not matter when no source has been configured for agent');

    my $emailAgentWithSource = EmailAgent->new({
        database => $database,
        configuration => clone($TEST_CONFIGURATION_EMAIL_AGENT_WITH_SOURCE),
    });

    ok($emailAgentWithSource->validItemSource($item1), 'an item with just a source of http://www.lboro.ac.uk/ should be valid');
    ok(!$emailAgentWithSource->validItemSource($item2), 'an item with just a source of http://www.google.com/ should not be valid');
    ok(!$emailAgentWithSource->validItemSource($item3), 'an item without a source should not be valid');
}

1;
