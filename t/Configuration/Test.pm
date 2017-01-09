use strict;
use warnings;

package Configuration::Test;

use base 'Test::Class';

use Configuration;

use Test::More;
use Test::Exception;
use Test::Deep;

use Fake::Database;

my $database;

sub setup : Test(setup) {
    $database = Fake::Database->new();
    $database->saveConfiguration({
        '_id' => 1,
        'title' => 'Test Configuration',
    });
}

sub _new : Test(2) {
    my $configuration = Configuration->new({
        database => $database,
    });
    isa_ok($configuration, 'Configuration');

    throws_ok {Configuration->new()} qr/missing required parameters/;
}

sub getAttribute : Test(3) {
    my $configuration = Configuration->new({
        database => $database,
        configurationId => 1,
    });
    isa_ok($configuration, 'Configuration');

    throws_ok {$configuration->getAttribute()} qr/missing required parameter/;

    ok($configuration->getAttribute('title') eq 'Test Configuration','should be able to retrieve a title attribute');
}

sub setAttribute : Test(3) {
    my $configuration = Configuration->new({
        database => $database,
        configurationId => 1,
    });
    isa_ok($configuration, 'Configuration');

    throws_ok {$configuration->setAttribute()} qr/missing required parameter/;

    $configuration->setAttribute({'title' => 'New test title'});
    ok($configuration->getAttribute('title') eq 'New test title','should be able to set and retrieve a title attribute');
}

sub saveConfiguration : Test(3) {
    my $configuration = Configuration->new({
        database => $database,
        configurationId => 1,
    });
    isa_ok($configuration, 'Configuration');

    $configuration->setAttribute({'title' => 'New test title'});
    ok($configuration->getAttribute('title') eq 'New test title','should be able to set and retrieve a title attribute');
    $configuration->save();
}

1;
