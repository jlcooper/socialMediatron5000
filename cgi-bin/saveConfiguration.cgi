#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/projects/socialMediatron5000/lib';

use CGI;
use JSON;

use TwitterBot;

my $cgi = CGI->new();

my $json = JSON->new;
$json->allow_blessed(1);
$json->convert_blessed(1);

my $configuration = {};

foreach my $parameter ($cgi->param()) {
    $configuration->{$parameter} = $cgi->param($parameter);
}

foreach my $field ('properties', 'order', 'types', 'sources', 'sets') {
    if ($configuration->{$field}) {
        $configuration->{$field} = [ split /\s*;\s*/, $configuration->{$field} ];
    }
}

foreach my $field ('active', 'icymi') {
    if ($configuration->{$field}) {
        $configuration->{$field} = lc($configuration->{$field}) eq "true"?1:0;
    }
}

print "Content-Type: application/json;charset=utf-8\n\n";
print $json->utf8(1)->encode(TwitterBot->saveConfiguration($configuration));
