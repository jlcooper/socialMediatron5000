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


print "Content-Type: application/json;charset=utf-8\n\n";
print $json->utf8(1)->encode(TwitterBot->getPublishingAgents());

