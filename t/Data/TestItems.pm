use strict;
use warnings;

package Data::TestItems;

use base 'Exporter';

use MongoDB::OID;
use Readonly;

our @EXPORT_OK = qw(
    $TEST_ITEM_1 $TEST_ITEM_2 $TEST_ITEM_3 $TEST_ITEM_4 $TEST_ITEM_5 $TEST_ITEM_6 $TEST_ITEM_7
    $TEST_ITEM_MISSING_STATUSES_1 $TEST_ITEM_MISSING_TIMESTAMPS_1 $TEST_ITEM_MISSING_STATUSES_AND_TIMESTAMPS_1
    $TEST_DUPLICATE_FIGSHARE_ITEM_1
);

Readonly our $TEST_ITEM_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Title',
    doi => '10.17028/rd.lboro.2005999',
    type => ['dataset'],
    statuses => {
        'Test Email Agent' => 'Pending',
        'Test Publisher 1' => 'Pending',
        'Test Publisher 2' => 'Done',
    },
    timestamps => {
        'Test Email Agent' => time() - (60 * 60 * 24 *30),
        'Test Publisher 1' => time() - (60 * 60 * 24 *30),
        'Test Publisher 2' => time() - (60 * 60 * 24 *25),
    },
    icymiTweet => '#dataset Test Title https://dx.doi.org/10.17028/rd.lboro.2005999',
    tweet => '#dataset Test Title https://dx.doi.org/10.17028/rd.lboro.2005999',
};


Readonly our $TEST_ITEM_2 => {
    title => 'Test Title 2',
    doi => '10.000/lboro.2',
    type => ['dataset'],
    statuses => {
        'Test Publisher 1' => 'Pending ICYMI',
        'Test Publisher 2' => 'Done',
        'Test Email Agent' => 'Done',
    },
    timestamps => {
        'Test Publisher 1' => time() - (60 * 60 * 24 *3),
        'Test Publisher 2' => time() - (60 * 60 * 24 *2),
        'Test Email Agent' => time() - (60 * 60 * 24 *2),
    },

};


Readonly our $TEST_ITEM_3 => {
    _id => MongoDB::OID->new(),
    title => 'Test Title 3',
    doi => '10.000/lboro.3',
    type => ['dataset'],
    statuses => {
        'Test Publisher 1' => 'Done',
        'Test Email Agent' => 'Done',
    },
    timestamps => {
        'Test Publisher 1' => time() - (60 * 60 * 24 *29),
        'Test Email Agent' => time() - (60 * 60 * 24 *29),
    },

};

Readonly our $TEST_ITEM_4 => {
    _id => MongoDB::OID->new(),
    title => 'Test Title 4',
    type => ['dataset'],
    doi => '10.000/lboro.4',
    statuses => {
    },
    timestamps => {
    },
};

Readonly our $TEST_ITEM_5 => {
    title => 'Test Title 5',
    doi => '10.17028/rd.lboro.2005377',
    type => ['dataset'],
    statuses => {
        'Test Publisher 1' => 'Pending ICYMI',
        'Test Email Agent' => 'Pending',
        'Test Publisher 2' => 'Done',
    },
    timestamps => {
        'Test Publisher 1' => time() - (60 * 60 * 24 *4),
        'Test Email Agent' => time() - (60 * 60 * 24 *4),
        'Test Publisher 2' => time() - (60 * 60 * 24 *2),
    },
    icymiTweet => 'icymi.. #dataset Test Title 5 https://dx.doi.org/10.17028/rd.lboro.2005377',
    tweet => '#dataset Test Title 5 https://dx.doi.org/10.17028/rd.lboro.2005377',
};

Readonly our $TEST_ITEM_6 => {
    title => 'Test Title 6',
    doi => '10.17028/rd.lboro.2005378',
    type => ['dataset'],
    statuses => {
        'Test Publisher 1' => 'Pending ICYMI',
        'Test Publisher 2' => 'Done',
        'Test Email Agent' => 'Done',
    },
    timestamps => {
        'Test Publisher 1' => time() - (60 * 60),
        'Test Publisher 2' => time() - (60 * 60),
        'Test Email Agent' => time() - (60 * 60),
    },
    icymiTweet => 'icymi.. #dataset Test Title 6 https://dx.doi.org/10.17028/rd.lboro.2005378',
    tweet => '#dataset Test Title 6 https://dx.doi.org/10.17028/rd.lboro.2005378',
};

Readonly our $TEST_ITEM_7 => {
    title => 'Test Title 7',
    doi => '10.17028/rd.lboro.2005379',
    type => ['dataset'],
    statuses => {
        'Test Publisher 1' => 'Pending',
        'Test Email Agent' => 'Pending',
        'Test Publisher 2' => 'Done',
    },
    timestamps => {
        'Test Publisher 1' => time() - (60 * 60),
        'Test Email Agent' => time() - (60 * 60),
        'Test Publisher 2' => time() - (60 * 60),
    },
    icymiTweet => 'icymi.. #dataset Test Title 6 https://dx.doi.org/10.17028/rd.lboro.2005378',
    tweet => '#dataset Test Title 6 https://dx.doi.org/10.17028/rd.lboro.2005378',
};


Readonly our $TEST_ITEM_MISSING_STATUSES_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Title 4',
    type => ['dataset'],
    doi => '10.000/lboro.4',
    timestamps => {
    },
};

Readonly our $TEST_ITEM_MISSING_TIMESTAMPS_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Title 4',
    type => ['dataset'],
    doi => '10.000/lboro.4',
    statuses => {
    },
};

Readonly our $TEST_ITEM_MISSING_STATUSES_AND_TIMESTAMPS_1 => {
    _id => MongoDB::OID->new(),
    title => 'Test Title 4',
    type => ['dataset'],
    doi => '10.000/lboro.4',
};

Readonly our $TEST_DUPLICATE_FIGSHARE_ITEM_1 => {
    title => 'Test Title',
    figshareId => 1,
    doi => '10.17028/rd.lboro.2005999',
    type => ['dataset'],
    statuses => {
        'Test Publisher 1' => 'Pending',
        'Test Publisher 2' => 'Done',
    },
    timestamps => {
        'Test Publisher 1' => time() - (60 * 60 * 24 *30),
        'Test Publisher 2' => time() - (60 * 60 * 24 *25),
    },
    icymiTweet => '#dataset Test Title https://dx.doi.org/10.17028/rd.lboro.2005999',
    tweet => '#dataset Test Title https://dx.doi.org/10.17028/rd.lboro.2005999',
};



1;
