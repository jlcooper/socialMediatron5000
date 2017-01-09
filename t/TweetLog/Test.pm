use strict;

package TweetLog::Test;

use base 'Test::Class';

use TweetLog;

use Test::More;
use Test::Exception;
use Test::Deep;

use Fake::Database;

use Data::TestTweets qw(
    $TEST_TWEET_1 $TEST_TWEET_2 $TEST_TWEET_3 $TEST_TWEET_4
    $COMPARE_TWEET_1 $COMPARE_TWEET_2 $COMPARE_TWEET_3 $COMPARE_TWEET_4
);

my $database;
my $tweetLog;

sub setup : Test(setup) {
    $database = Fake::Database->new();

    $tweetLog = TweetLog->new({
        database=> $database
    });
}

sub _new : Test(2) {
    throws_ok {TweetLog->new()} qr/missing required parameters/;
    isa_ok($tweetLog, 'TweetLog');
}

sub saveTweet : Test(5) {
    throws_ok {$tweetLog->saveTweet()} qr/missing required parameters/;

    $tweetLog->saveTweet($TEST_TWEET_1);
    my $tweets = $database->getTweets();
    cmp_deeply($tweets, bag($COMPARE_TWEET_1), 'first saved tweet should be in the database');

    $tweetLog->saveTweet($TEST_TWEET_2);
    $tweets = $database->getTweets();
    cmp_deeply($tweets, bag($COMPARE_TWEET_1, $COMPARE_TWEET_2), 'first and second saved tweets should be in the database');

    $tweetLog->saveTweet($TEST_TWEET_3);
    $tweets = $database->getTweets();
    cmp_deeply($tweets, bag($COMPARE_TWEET_1, $COMPARE_TWEET_2, $COMPARE_TWEET_3), 'first, second and thrid saved tweets should be in the database');

    $tweetLog->saveTweet($TEST_TWEET_4);
    $tweets = $database->getTweets();
    cmp_deeply($tweets, bag($COMPARE_TWEET_1, $COMPARE_TWEET_2, $COMPARE_TWEET_3, $COMPARE_TWEET_4), 'first, second, third and fourth saved tweets should be in the database');
}

sub getTweetsSince : Test(3) {
    throws_ok {$tweetLog->getTweetsSince()} qr/missing required parameters/;
    throws_ok {$tweetLog->getTweetsSince("Not a valid date")} qr/timestamp must be an epoch/;

    $tweetLog->saveTweet($TEST_TWEET_1);
    $tweetLog->saveTweet($TEST_TWEET_2);
    $tweetLog->saveTweet($TEST_TWEET_3);
    $tweetLog->saveTweet($TEST_TWEET_4);

    my $tweets = $tweetLog->getTweetsSince(1447845000);
    cmp_deeply($tweets, bag($COMPARE_TWEET_3, $COMPARE_TWEET_4), 'getTweetsSince should only return tweets with a later timestamp');
}

1;
