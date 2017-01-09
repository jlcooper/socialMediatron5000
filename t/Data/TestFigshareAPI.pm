use strict;
use warnings;

package Data::TestFigshareAPI;

use base 'Exporter';

use MongoDB::OID;
use Readonly;
use Perl6::Slurp;

our @EXPORT_OK = qw(
    $PUBLICATIONS_SINCE_1 $PUBLICATIONS_SINCE_TERMINATOR

    $PUBLICATION_1 $HARVESTED_ITEM_1 $TITLE_TWEET_ITEM_1
    $PUBLICATION_2 $HARVESTED_ITEM_2 $TITLE_TWEET_ITEM_2
    $PUBLICATION_3 $HARVESTED_ITEM_3 $TITLE_TWEET_ITEM_3
    $PUBLICATION_4 $HARVESTED_ITEM_4 $TITLE_TWEET_ITEM_4
    $PUBLICATION_5 $HARVESTED_ITEM_5 $TITLE_TWEET_ITEM_5
    $PUBLICATION_6 $HARVESTED_ITEM_6 $TITLE_TWEET_ITEM_6
    $PUBLICATION_7 $HARVESTED_ITEM_7 $TITLE_TWEET_ITEM_7
    $PUBLICATION_8 $HARVESTED_ITEM_8 $TITLE_TWEET_ITEM_8

    @ARTICLE_IDS
);

Readonly our $PUBLICATIONS_SINCE_1 => {
    status => 200,
    response => scalar slurp 't/Data/FigshareAPI/articles_1.json',
};

Readonly our $PUBLICATIONS_SINCE_TERMINATOR => {
    status => 200,
    response => "[]",
};


Readonly our $PUBLICATION_1 => {
    url => "https://api.figshare.com/v2/articles/2005377",
    doi => "10.17028/rd.lboro.2005377",
    id => 2005377,
    publishedDate => "2015-11-10T15:46:22",
    title => "Variational energy method vibration code",
    tags => [
        "vibrational modes"
    ],
    categories => [
        "Dynamics, Vibration and Vibration Control"
    ],
};

Readonly our $HARVESTED_ITEM_1 => {
    url => "https://api.figshare.com/v2/articles/2005377",
    doi => "10.17028/rd.lboro.2005377",
    figshareId => 2005377,
    publishedDate => "2015-11-10T15:46:22",
    title => "Variational energy method vibration code",
    tags => [
        "vibrational modes"
    ],
    categories => [
        "Dynamics, Vibration and Vibration Control"
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_1 => "#dataset Variational energy method vibration code https://dx.doi.org/10.17028/rd.lboro.2005377";

Readonly our $PUBLICATION_2 => {
    url => "https://api.figshare.com/v2/articles/2002947",
    doi => "10.17028/rd.lboro.2002947",
    id => 2002947,
    publishedDate => "2015-10-14T14:38:52",
    title => "Data/appendices to: Chesil Beach grain-size report: A technical report on the impact of beach management works and evaluation of the Sedimetrics Digital Gravelometer software",
    tags => [
        "Chesil Beach",
        "Grain-size analysis",
        "Sedimetrics Digital Gravelometer",
        "Centre for Hydrology and Ecosystem Research",
        "Changing Environments and Infrastructure",
    ],
    categories => [
        "Physical Geography",
    ],
};

Readonly our $HARVESTED_ITEM_2 => {
    url => "https://api.figshare.com/v2/articles/2002947",
    doi => "10.17028/rd.lboro.2002947",
    figshareId => 2002947,
    publishedDate => "2015-10-14T14:38:52",
    title => "Data/appendices to: Chesil Beach grain-size report: A technical report on the impact of beach management works and evaluation of the Sedimetrics Digital Gravelometer software",
    tags => [
        "Chesil Beach",
        "Grain-size analysis",
        "Sedimetrics Digital Gravelometer",
        "Centre for Hydrology and Ecosystem Research",
        "Changing Environments and Infrastructure",
    ],
    categories => [
        "Physical Geography",
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_2 => "#dataset Data/appendices to: Chesil Beach grain-size report: A technical report on the impact o https://dx.doi.org/10.17028/rd.lboro.2002947";

Readonly our $PUBLICATION_3 => {
    url => "https://api.figshare.com/v2/articles/2001129",
    doi => "10.17028/rd.lboro.2001129",
    id => 2001129,
    publishedDate => "2015-09-16T17:01:37",
    title => "CREST Demand Model v2.0",
    tags => [
        "energy demand modelling",
        "domestic electricity use",
        "domestic heat use",
        "bottom-up model",
        "stochastic",
        "high-resolution"
    ],
    categories => [
        "Software Engineering"
    ],
};

Readonly our $HARVESTED_ITEM_3 => {
    url => "https://api.figshare.com/v2/articles/2001129",
    doi => "10.17028/rd.lboro.2001129",
    figshareId => 2001129,
    publishedDate => "2015-09-16T17:01:37",
    title => "CREST Demand Model v2.0",
    tags => [
        "energy demand modelling",
        "domestic electricity use",
        "domestic heat use",
        "bottom-up model",
        "stochastic",
        "high-resolution"
    ],
    categories => [
        "Software Engineering"
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_3 => "#dataset CREST Demand Model v2.0 https://dx.doi.org/10.17028/rd.lboro.2001129";

Readonly our $PUBLICATION_4 => {
    url => "https://api.figshare.com/v2/articles/2000901",
    doi => "10.17028/rd.lboro.2000901",
    id => 2000901,
    publishedDate => "2015-08-13T09:57:01",
    title => "Microstrip Patch Antennas with Anisotropic and Diamagnetic Synthetic Heterogeneous Substrates - Data Set",
    tags => [
        "Metamaterials",
        "Electrical Engineering",
    ],
    categories => [
        "Computer Engineering",
    ],
};

Readonly our $HARVESTED_ITEM_4 => {
    url => "https://api.figshare.com/v2/articles/2000901",
    doi => "10.17028/rd.lboro.2000901",
    figshareId => 2000901,
    publishedDate => "2015-08-13T09:57:01",
    title => "Microstrip Patch Antennas with Anisotropic and Diamagnetic Synthetic Heterogeneous Substrates - Data Set",
    tags => [
        "Metamaterials",
        "Electrical Engineering",
    ],
    categories => [
        "Computer Engineering",
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_4 => "#dataset Microstrip Patch Antennas with Anisotropic and Diamagnetic Synthetic Heterogeneous Substrates - Data Set https://dx.doi.org/10.17028/rd.lboro.2000901";

Readonly our $PUBLICATION_5 => {
    url => "https://api.figshare.com/v2/articles/2001888",
    doi => "10.17028/rd.lboro.2001888",
    id => 2001888,
    publishedDate => "2015-08-11T19:23:26",
    title => "Flexible three-dimensional printed antenna substrates",
    tags => [
        "Antenna",
    ],
    categories => [
        "Computer Engineering",
    ],
};

Readonly our $HARVESTED_ITEM_5 => {
    url => "https://api.figshare.com/v2/articles/2001888",
    doi => "10.17028/rd.lboro.2001888",
    figshareId => 2001888,
    publishedDate => "2015-08-11T19:23:26",
    title => "Flexible three-dimensional printed antenna substrates",
    tags => [
        "Antenna",
    ],
    categories => [
        "Computer Engineering",
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_5 => "#dataset Flexible three-dimensional printed antenna substrates https://dx.doi.org/10.17028/rd.lboro.2001888";

Readonly our $PUBLICATION_6 => {
    url => "https://api.figshare.com/v2/articles/2001255",
    doi => "10.17028/rd.lboro.2001255",
    id => 2001255,
    publishedDate => "2015-07-07T22:47:09",
    title => "Patch Size Reduction of Rectangular Microstrip Antennas by Means of a Cuboid Ridge",
    tags => [
        "Antenna",
        "microstrip",
    ],
    categories => [
        "Computer Engineering",
    ],
};

Readonly our $HARVESTED_ITEM_6 => {
    url => "https://api.figshare.com/v2/articles/2001255",
    doi => "10.17028/rd.lboro.2001255",
    figshareId => 2001255,
    publishedDate => "2015-07-07T22:47:09",
    title => "Patch Size Reduction of Rectangular Microstrip Antennas by Means of a Cuboid Ridge",
    tags => [
        "Antenna",
        "microstrip",
    ],
    categories => [
        "Computer Engineering",
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_6 => "#dataset Patch Size Reduction of Rectangular Microstrip Antennas by Means of a Cuboid Ridge https://dx.doi.org/10.17028/rd.lboro.2001255";

Readonly our $PUBLICATION_7 => {
    url => "https://api.figshare.com/v2/articles/2001054",
    doi => "10.17028/rd.lboro.2001054",
    id => 2001054,
    publishedDate => "2015-06-25T13:14:26",
    title => "Cable impedance data",
    tags => [
        "Finite element",
        "AC resistance",
        "Proximity effect",
        "Skin effect",
        "Sector conductors",
        "Cable impedance",
        "CREST",
    ],
    categories => [
        "Computer Engineering",
        "Climate Science",
    ],
};

Readonly our $HARVESTED_ITEM_7 => {
    url => "https://api.figshare.com/v2/articles/2001054",
    doi => "10.17028/rd.lboro.2001054",
    figshareId => 2001054,
    publishedDate => "2015-06-25T13:14:26",
    title => "Cable impedance data",
    tags => [
        "Finite element",
        "AC resistance",
        "Proximity effect",
        "Skin effect",
        "Sector conductors",
        "Cable impedance",
        "CREST",
    ],
    categories => [
        "Computer Engineering",
        "Climate Science",
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_7 => "#dataset Cable impedance data https://dx.doi.org/10.17028/rd.lboro.2001054";

Readonly our $PUBLICATION_8 => {
    url => "https://api.figshare.com/v2/articles/2000997",
    doi => "10.17028/rd.lboro.2000997",
    id => 2000997,
    publishedDate => "2015-06-23T12:46:32",
    title => "Novel 3D printed synthetic dielectric substrates-data",
    tags => [
        "Electronic Engineering",
        "WiCR",
        "3D printing",
        "synthetic materials",
        "dielectric substrates",
        "Antenna",
    ],
    categories => [
        "Computer Engineering",
    ],
};

Readonly our $HARVESTED_ITEM_8 => {
    url => "https://api.figshare.com/v2/articles/2000997",
    doi => "10.17028/rd.lboro.2000997",
    figshareId => 2000997,
    publishedDate => "2015-06-23T12:46:32",
    title => "Novel 3D printed synthetic dielectric substrates-data",
    tags => [
        "Electronic Engineering",
        "WiCR",
        "3D printing",
        "synthetic materials",
        "dielectric substrates",
        "Antenna",
    ],
    categories => [
        "Computer Engineering",
    ],
    statuses => {},
    timestamps => {},
    type => ['dataset'],
};

Readonly our $TITLE_TWEET_ITEM_8 => "#dataset Novel 3D printed synthetic dielectric substrates-data https://dx.doi.org/10.17028/rd.lboro.2000997";

Readonly our @ARTICLE_IDS => qw(
    2005377 2002947 2001129 2000901 2001888 2001255 2001054 2000997
);

1;
