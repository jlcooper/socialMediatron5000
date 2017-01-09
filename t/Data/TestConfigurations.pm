use strict;
use warnings;

package Data::TestConfigurations;

use base 'Exporter';

use MongoDB::OID;
use Readonly;

our @EXPORT_OK = qw(
    $TEST_CONFIGURATION_1 $TEST_CONFIGURATION_2 $TEST_CONFIGURATION_3
    $TEST_CONFIGURATION_4 $TEST_CONFIGURATION_5 $TEST_CONFIGURATION_6
    $TEST_CONFIGURATION_7 $TEST_CONFIGURATION_8

    $TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD
    $TEST_CONFIGURATION_8_INSIDE_HARVEST_PERIOD
    $TEST_CONFIGURATION_9_INSIDE_HARVEST_PERIOD

    $TEST_CONFIGURATION_4_WITHOUT_ICYMI
    $TEST_CONFIGURATION_4_WITH_SOURCE
    $TEST_CONFIGURATION_4_WITH_SET

    $TEST_CONFIGURATION_8_WITH_BLACKLIST
    $TEST_CONFIGURATION_8_WITH_WHITELIST
    $TEST_CONFIGURATION_8_WITH_TYPES
    $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES

    $TEST_CONFIGURATION_9 $TEST_CONFIGURATION_10 $TEST_CONFIGURATION_11

    $TEST_CONFIGURATION_FACEBOOK_AGENT_1

    $TEST_CONFIGURATION_EMAIL_AGENT $TEST_CONFIGURATION_EMAIL_AGENT_WITH_SOURCE

    $TEST_ERROR_CONFIGURATION_7  $TEST_ERROR_CONFIGURATION_8
    $TEST_ERROR_CONFIGURATION_9

    $INTEGRATION_CONFIGURATION_1 $INTEGRATION_CONFIGURATION_2
    $INTEGRATION_CONFIGURATION_3 $INTEGRATION_CONFIGURATION_4
    $INTEGRATION_CONFIGURATION_5 $INTEGRATION_CONFIGURATION_6
    $INTEGRATION_CONFIGURATION_7 $INTEGRATION_CONFIGURATION_8
);


Readonly our $TEST_CONFIGURATION_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 1',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::LupinAgent',
};

Readonly our $TEST_CONFIGURATION_2 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 2',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::LupinAgent',
};

Readonly our $TEST_CONFIGURATION_3 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 3',
    properties => ['harvester'],
    active => 0,
    agent => 'Fake::LupinAgent',
};

Readonly our $TEST_CONFIGURATION_4 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 1',
    properties => ['publisher'],
    types => ['dataset'],
    active => 1,
    agent => 'Fake::TwitterAgent',
    hashtags => ['#dataset'],
    order => ['hashtags', 'title', 'doi'],
    shortenToFit => 'title',
    icymiThreshold => 64800,
    icymi => 1,
    tweetThreshold => 120,
    lastTweeted => time() - (60 * 60),
};

Readonly our $TEST_CONFIGURATION_4_WITH_SOURCE => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 1',
    properties => ['publisher'],
    types => ['dataset'],
    active => 1,
    agent => 'Fake::TwitterAgent',
    hashtags => ['#dataset'],
    order => ['hashtags', 'title', 'doi'],
    shortenToFit => 'title',
    icymiThreshold => 64800,
    icymi => 1,
    tweetThreshold => 120,
    lastTweeted => time() - (60 * 60),
    sources => ['http://www.lboro.ac.uk/'],
};

Readonly our $TEST_CONFIGURATION_4_WITH_SET => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 1',
    properties => ['publisher'],
    types => ['dataset'],
    active => 1,
    agent => 'Fake::TwitterAgent',
    hashtags => ['#dataset'],
    order => ['hashtags', 'title', 'doi'],
    shortenToFit => 'title',
    icymiThreshold => 64800,
    icymi => 1,
    tweetThreshold => 120,
    lastTweeted => time() - (60 * 60),
    sets => ['Big set', 'Small set'],
};
Readonly our $TEST_CONFIGURATION_4_WITHOUT_ICYMI => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 1',
    properties => ['publisher'],
    types => ['dataset'],
    active => 1,
    agent => 'Fake::TwitterAgent',
    hashtags => ['#dataset'],
    order => ['hashtags', 'title', 'doi'],
    shortenToFit => 'title',
    icymiThreshold => 64800,
};

Readonly our $TEST_CONFIGURATION_5 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 2',
    properties => ['publisher'],
    active => 1,
    agent => 'Fake::TwitterAgent',
    hashtags => ['#dataset2'],
    types => ['dataset'],
    icymiThreshold => 64800,
};

Readonly our $TEST_CONFIGURATION_6 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 3',
    properties => ['publisher'],
    active => 0,
    agent => 'Fake::TwitterAgent',
    hashtags => ['#dataset3'],
    types => ['dataset'],
    icymiThreshold => 64800,
};

Readonly our $TEST_CONFIGURATION_7 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::FigshareAgent',
    institutionId => 2,
    apiUrl => 'https://localhost/v2',
    publishedSince => '2015-11-01',
};

Readonly our $TEST_CONFIGURATION_7_INSIDE_HARVEST_PERIOD => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::FigshareAgent',
    institutionId => 2,
    apiUrl => 'https://localhost/v2',
    publishedSince => '2015-11-01',
    lastHarvested => time() - 50,
    timeBetweenHarvests => 1000,
};


Readonly our $TEST_ERROR_CONFIGURATION_7 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::FigshareAgent',
};

Readonly our $TEST_CONFIGURATION_8 => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
};

Readonly our $TEST_CONFIGURATION_8_INSIDE_HARVEST_PERIOD => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
    lastHarvested => time() - 50,
    timeBetweenHarvests => 1000,
};



Readonly our $TEST_ERROR_CONFIGURATION_8 => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
};

Readonly our $TEST_CONFIGURATION_8_WITH_BLACKLIST => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
    blackList => 'Closed',
};

Readonly our $TEST_CONFIGURATION_8_WITH_WHITELIST => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
    whiteList => '^(Pre-Prints \(Physics\)|Published Articles \(Physics\))',
};

Readonly our $TEST_CONFIGURATION_8_WITH_TYPES => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
    types => [
        'Article',
        'Conference Contribution',
    ],
};

Readonly our $TEST_CONFIGURATION_8_WITH_BLACKLIST_AND_TYPES => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
    blackList => 'Closed',
    types => [
        'Article',
        'Conference Contribution',
    ],
};

Readonly our $TEST_CONFIGURATION_9 => {
    _id => MongoDB::OID->new(),
    title => 'Test RSS Feed Harvesting Configuration',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::RSSAgent',
    rssUrl => "http://www.lboro.ac.uk/services/it/announcements/rss/index.xml",
};


Readonly our $TEST_CONFIGURATION_9_INSIDE_HARVEST_PERIOD => {
    _id => MongoDB::OID->new(),
    title => 'Test RSS Feed Harvesting Configuration',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::RSSAgent',
    rssUrl => "http://www.lboro.ac.uk/services/it/announcements/rss/index.xml",
    lastHarvested => time() - 50,
    timeBetweenHarvests => 1000,
};



Readonly our $TEST_ERROR_CONFIGURATION_9 => {
    _id => MongoDB::OID->new(),
    title => 'Test RSS Feed Harvesting Configuration',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::RSSAgent',
};

Readonly our $TEST_CONFIGURATION_10 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 10',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::FigshareAgent',
    institutionId => 2,
    apiUrl => 'https://localhost/v2',
    publishedSince => '2015-11-01',
    lastHarvested => time - (60 * 60 * 24),
    timeBetweenHarvests => 60,
};

Readonly our $TEST_CONFIGURATION_11 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 10',
    properties => ['harvester'],
    active => 1,
    agent => 'Fake::FigshareAgent',
    institutionId => 2,
    apiUrl => 'https://localhost/v2',
    publishedSince => '2015-11-01',
    lastHarvested => time - (60),
    timeBetweenHarvests => (60 * 60 * 24),
};


Readonly our $TEST_CONFIGURATION_FACEBOOK_AGENT_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 2',
    properties => ['publisher'],
    types => ['Feed Entry'],
    active => 1,
    agent => 'Fake::FacebookAgent',
    order => ['title', 'description'],
    link => 'url',
    lastPosted => time() - (60 * 60),
    postThreshold => 120,
    thumbnailId => ''
};

Readonly our $TEST_CONFIGURATION_EMAIL_AGENT => {
    _id => MongoDB::OID->new(),
    title => 'Test Email Agent',
    properties => ['publisher'],
    types => ['dataset'],
    active => 1,
    agent => 'Fake::EmailAgent',
    order => ['title', 'doi'],
    emailThreshold => 120,
    lastEmailed => time() - (60 * 60),
    emailHeader => "Latest items available:\n",
    emailFooter => "\n---\nSocial Mediatron 5000\n",
};

Readonly our $TEST_CONFIGURATION_EMAIL_AGENT_WITH_SOURCE => {
    _id => MongoDB::OID->new(),
    title => 'Test Email Agent',
    properties => ['publisher'],
    types => ['dataset'],
    active => 1,
    agent => 'Fake::EmailAgent',
    order => ['title', 'doi'],
    emailThreshold => 120,
    lastEmailed => time() - (60 * 60),
    emailHeader => "Latest items available:\n",
    emailFooter => "\n---\nSocial Mediatron 5000\n",
    sources => ['http://www.lboro.ac.uk/'],
};




Readonly our $INTEGRATION_CONFIGURATION_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Harvesting Configuration 1',
    properties => ['harvester'],
    active => 1,
    agent => 'FigshareAgent',
    institutionId => 2,
    apiUrl => 'https://api.figshare.com/v2',
    publishedSince => '2015-11-01',
    lastHarvested => time() - 5000,
    timeBetweenHarvests => 1000,
};

Readonly our $INTEGRATION_CONFIGURATION_2 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 1',
    properties => ['publisher'],
    active => 1,
    agent => 'TwitterAgent',
    hashtags => ['#dataset'],
    order => ['hashtags', 'title', 'doi'],
    shortenToFit => 'title',
    types => ['dataset'],
    icymi => 1,
};

Readonly our $INTEGRATION_CONFIGURATION_3 => {
    _id => MongoDB::OID->new(),
    title => 'Test Dspace Harvesting Configuration 7',
    properties => ['harvester'],
    active => 1,
    agent => 'DspaceAgent',
    oaipmhBaseUrl => "https://dspace.lboro.ac.uk/dspace-oai/request",
    publishedSince => '2016-01-03 00:00:00',
    blackList => 'Closed',
    types => [
        'Article',
        'Conference Contribution',
    ],
    lastHarvested => time() - 5000,
    timeBetweenHarvests => 1000,
};

Readonly our $INTEGRATION_CONFIGURATION_4 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 2',
    properties => ['publisher'],
    active => 1,
    agent => 'TwitterAgent',
    hashtags => ['#publication'],
    order => ['hashtags', 'title', 'url'],
    shortenToFit => 'title',
    types => ['Article', 'Conference Contribution'],
    icymi => 0,
    tweetThreshold => 120,
};

Readonly our $INTEGRATION_CONFIGURATION_5 => {
    _id => MongoDB::OID->new(),
    title => 'Test RSS Feed Harvesting Configuration',
    properties => ['harvester'],
    active => 1,
    agent => 'RSSAgent',
    rssUrl => "http://www.lboro.ac.uk/services/it/announcements/rss/index.xml",
    lastHarvested => time() - 5000,
    timeBetweenHarvests => 1000,
};

Readonly our $INTEGRATION_CONFIGURATION_6 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 3',
    properties => ['publisher'],
    active => 1,
    agent => 'TwitterAgent',
    hashtags => [],
    order => ['title', 'url'],
    shortenToFit => 'title',
    types => ['Feed Entry'],
    icymi => 0,
};

Readonly our $INTEGRATION_CONFIGURATION_7 => {
    _id => MongoDB::OID->new(),
    title => 'Test Email Agent',
    properties => ['publisher'],
    types => ['Article', 'Conference Contribution'],
    active => 1,
    agent => 'EmailAgent',
    order => ['title', 'url'],
    emailThreshold => 120,
    lastEmailed => time() - (60 * 60),
    emailHeader => "Latest items available:\n",
    emailFooter => "\n---\nSocial Mediatron 5000\n",
    emailFrom => "a.n.other\@example.com",
    emailTo => "a.n.other\@example.com",
};

Readonly our $INTEGRATION_CONFIGURATION_8 => {
    _id => MongoDB::OID->new(),
    title => 'Test Publisher 2',
    properties => ['publisher'],
    types => ['Feed Entry'],
    active => 1,
    agent => 'FacebookAgent',
    order => ['title', 'description'],
    link => 'url',
    lastPosted => time() - (60 * 60),
    postThreshold => 120,
    thumbnailId => ''
};



1;
