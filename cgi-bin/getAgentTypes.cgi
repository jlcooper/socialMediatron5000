#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;

my $cgi = CGI->new();

my $json = JSON->new;
$json->allow_blessed(1);
$json->convert_blessed(1);

my $agentTypes = {
    harvester => [
        {
            agent => 'FigshareAgent',
            fields => {
                title => {
                    type => 'text',
                    label => 'Title',
                    order => 1,
                },
                institutionId => {
                    type => 'number',
                    label => 'Institution ID',
                    order => 3,
                },
                apiUrl => {
                    type => 'url',
                    label => 'API URL',
                    order => 2,
                },
                publishedSince => {
                    type => 'date',
                    label => 'Harvest items published since',
                    order => 4,
                },
                timeBetweenHarvests => {
                    type => 'number',
                    label => 'Minimum seconds between harvests',
                    order => 5,
                },
                active => {
                    type => 'checkbox',
                    label => 'Active',
                    order => 6,
                },
                "properties" => {
                    type => 'hidden',
                    value => 'harvester',
                    order => 20,
                },
            },
        },{
            agent => 'DspaceAgent',
            fields => {
                title => {
                    type => 'text',
                    label => 'Title',
                    order => 1,
                },
                oaipmhBaseUrl => {
                    type => 'url',
                    label => 'OAIPMH Base URL',
                    order => 2,
                },
                publishedSince => {
                    type => 'text',
                    label => 'Harvest items published since (YYYY-MM-DD HH:MM:SS)',
                    order => 4,
                },
                blackList => {
                    type => 'text',
                    label => 'Black List',
                    order => 5,
                },
                whiteList => {
                    type => 'text',
                    label => 'White List',
                    order => 6,
                },
                types => {
                    type => 'text',
                    label => 'Item Types',
                    order => 7,
                },
                timeBetweenHarvests => {
                    type => 'number',
                    label => 'Minimum seconds between harvests',
                    order => 8,
                },
                active => {
                    type => 'checkbox',
                    label => 'Active',
                    order => 9,
                },
                "properties" => {
                    type => 'hidden',
                    value => 'harvester',
                    order => 20,
                },
            },
        },{
            agent => 'RSSAgent',
            fields => {
                title => {
                    type => 'text',
                    label => 'Title',
                    order => 1,
                },
                rssUrl => {
                    type => 'url',
                    label => 'RSS Feed URL',
                    order => 2,
                },
                timeBetweenHarvests => {
                    type => 'number',
                    label => 'Minimum seconds between harvests',
                    order => 3,
                },
                active => {
                    type => 'checkbox',
                    label => 'Active',
                    order => 5,
                },
                "properties" => {
                    type => 'hidden',
                    value => 'harvester',
                    order => 20,
                },
            },
        },
    ],
    publisher => [
        {
            agent => 'TwitterAgent',
            fields => {
                title => {
                    type => 'text',
                    label => 'Title',
                    order => 1,
                },
                types => {
                    type => 'text',
                    label => 'Publication types',
                    order => 2
                },
                sources => {
                    type => 'text',
                    label => 'Sources',
                    order => 3
                },
                sets => {
                    type => 'text',
                    label => 'Sets',
                    order => 4
                },
                order => {
                    type => 'text',
                    label => 'Field order',
                    order => 5,
                },
                hashtags => {
                    type => 'text',
                    label => 'Hashtags',
                    order => 6,
                },
                shortenToFit => {
                    type => 'text',
                    label => 'Field to shorten to fit',
                    order => 7,
                },
                tweetThreshold => {
                    type => 'number',
                    label => 'Minimum wait between making any tweets (seconds)',
                    order => 8,
                },
                icymi => {
                    type => 'checkbox',
                    label => 'Make "ICYMI" posts',
                    order => 9,
                },
                icymiThreshold => {
                    type => 'number',
                    label => 'Minimum wait before sending ICYMI (seconds)',
                    order => 10,
                },
                consumer_key => {
                    type => 'text',
                    label => 'Consumer key',
                    order => 11,
                },
                consumer_secret => {
                    type => 'text',
                    label => 'Consumer secret',
                    order => 12,
                },
                access_token => {
                    type => 'text',
                    label => 'Access token',
                    order => 13,
                },
                access_token_secret => {
                    type => 'text',
                    label => 'Access token secret',
                    order => 14,
                },
                active => {
                    type => 'checkbox',
                    label => 'Active',
                    order => 15,
                },
                "properties" => {
                    type => 'hidden',
                    value => 'publisher',
                    order => 20,
                },
            }
        }, {
            agent => 'EmailAgent',
            fields => {
                title => {
                    type => 'text',
                    label => 'Title',
                    order => 1,
                },
                types => {
                    type => 'text',
                    label => 'Publication types',
                    order => 2
                },
                sources => {
                    type => 'text',
                    label => 'Sources',
                    order => 3
                },
                sets => {
                    type => 'text',
                    label => 'Sets',
                    order => 4
                },
                order => {
                    type => 'text',
                    label => 'Field order',
                    order => 5,
                },
                emailThreshold => {
                    type => 'number',
                    label => 'Minimum wait between sending Digest Email (seconds)',
                    order => 8,
                },
                emailFrom => {
                    type => 'email',
                    label => 'Address to send email as',
                    order => 9,
                },
                emailTo => {
                    type => 'email',
                    label => 'Address to send digest email to',
                    order => 10,
                },
                emailSubject => {
                    type => 'text',
                    label => 'Subject of digest email',
                    order => 11,
                },
                emailHeader => {
                    type => 'textarea',
                    label => 'Email header',
                    order => 12,
                },
                emailFooter => {
                    type => 'textarea',
                    label => 'Email footer',
                    order => 13,
                },
                active => {
                    type => 'checkbox',
                    label => 'Active',
                    order => 15,
                },
                "properties" => {
                    type => 'hidden',
                    value => 'publisher',
                    order => 20,
                },
            }
        }, {
            agent => 'FacebookAgent',
            fields => {
                title => {
                    type => 'text',
                    label => 'Title',
                    order => 1,
                },
                types => {
                    type => 'text',
                    label => 'Publication types',
                    order => 2
                },
                sources => {
                    type => 'text',
                    label => 'Sources',
                    order => 3
                },
                sets => {
                    type => 'text',
                    label => 'Sets',
                    order => 4
                },
                order => {
                    type => 'text',
                    label => 'Field order',
                    order => 5,
                },
                link => {
                    type => 'text',
                    label => 'Link field',
                    order => 6,
                },
                imageUrl => {
                    type => 'url',
                    label => 'Image URL',
                    order => 7,
                },
                postThreshold => {
                    type => 'number',
                    label => 'Minimum wait between posting to page (seconds)',
                    order => 8,
                },
                pageId => {
                    type => 'text',
                    label => 'Page ID',
                    order => 10,
                },
                accessToken => {
                    type => 'text',
                    label => 'Page access token',
                    order => 11,
                },
                active => {
                    type => 'checkbox',
                    label => 'Active',
                    order => 15,
                },
                "properties" => {
                    type => 'hidden',
                    value => 'publisher',
                    order => 20,
                },
            }
        }
    ],
};


print "Content-Type: application/json;charset=utf-8\n\n";
print $json->utf8(1)->encode($agentTypes);

