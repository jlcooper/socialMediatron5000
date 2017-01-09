use strict;
use warnings;

package Data::TestRSSAPI;

use base 'Exporter';

use MongoDB::OID;
use Readonly;
use Perl6::Slurp;


our @EXPORT_OK = qw(
    $RSS_FEED_1

    $ITEM_1  $ITEM_2  $ITEM_3  $ITEM_4  $ITEM_5
    $ITEM_6  $ITEM_7  $ITEM_8  $ITEM_9  $ITEM_10
    $ITEM_11 $ITEM_12 $ITEM_13 $ITEM_14 $ITEM_15
    $ITEM_16

    $HARVESTED_ITEM_1  $HARVESTED_ITEM_2  $HARVESTED_ITEM_3  $HARVESTED_ITEM_4
    $HARVESTED_ITEM_5  $HARVESTED_ITEM_6  $HARVESTED_ITEM_7  $HARVESTED_ITEM_8
    $HARVESTED_ITEM_9  $HARVESTED_ITEM_10 $HARVESTED_ITEM_11 $HARVESTED_ITEM_12
    $HARVESTED_ITEM_13 $HARVESTED_ITEM_14 $HARVESTED_ITEM_15 $HARVESTED_ITEM_16

    $TITLE_TWEET_ITEM_1  $TITLE_TWEET_ITEM_2  $TITLE_TWEET_ITEM_3  $TITLE_TWEET_ITEM_4
    $TITLE_TWEET_ITEM_5  $TITLE_TWEET_ITEM_6  $TITLE_TWEET_ITEM_7  $TITLE_TWEET_ITEM_8
    $TITLE_TWEET_ITEM_9  $TITLE_TWEET_ITEM_10 $TITLE_TWEET_ITEM_11 $TITLE_TWEET_ITEM_12
    $TITLE_TWEET_ITEM_13 $TITLE_TWEET_ITEM_14 $TITLE_TWEET_ITEM_15 $TITLE_TWEET_ITEM_16

    $TITLE_POST_ITEM_1  $TITLE_POST_ITEM_2  $TITLE_POST_ITEM_3  $TITLE_POST_ITEM_4
    $TITLE_POST_ITEM_5  $TITLE_POST_ITEM_6  $TITLE_POST_ITEM_7  $TITLE_POST_ITEM_8
    $TITLE_POST_ITEM_9  $TITLE_POST_ITEM_10 $TITLE_POST_ITEM_11 $TITLE_POST_ITEM_12
    $TITLE_POST_ITEM_13 $TITLE_POST_ITEM_14 $TITLE_POST_ITEM_15 $TITLE_POST_ITEM_16
);


Readonly our $RSS_FEED_1 => {
    url => "http://www.lboro.ac.uk/services/it/announcements/rss/index.xml",
    status => 200,
    response => scalar slurp 't/Data/RSSAPI/rss_feed_1.xml',
};


Readonly our $ITEM_1 => {
    title => 'New NVivo Licence for 2016/2017',
    description => "<p><strong>Specialist Software Downloads Now Available Via LEARN.</strong></p>
<p>The new NVivo 2016 / 2017 licence is now available to download via the LEARN system. To download the latest version, please visit\x{a0}<a href=\"http://learn.lboro.ac.uk/course/view.php?id=9766\">http://learn.lboro.ac.uk/course/view.php?id=9766</a></p>
<h4><strong>Other specialist software currently available:</strong></h4>
<p class=\"sectionname\" id=\"yui_3_17_2_3_1462455037496_309\">IBM SPSS Statistics 22</p>
<p class=\"sectionname\" id=\"yui_3_17_2_3_1462455037496_316\">Maplesoft Maple 2015</p>
<p class=\"sectionname\">Siemens PLM NX 8.5.3</p>
<div class=\"content\">
<p class=\"sectionname\">Mindjet MindManager</p>
<p class=\"sectionname\">Granta CES EduPack 2015</p>
<p class=\"sectionname\"><span>National Instruments LabVIEW (Engineering Students Only)</span></p>
<p class=\"sectionname\" id=\"yui_3_17_2_3_1462455037496_327\">OriginLab</p>
<p class=\"sectionname\">Matlab</p>
<p class=\"sectionname\">\x{a0}</p>
<p class=\"sectionname\">IT Services</p>
</div>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/new-nvivo-licence-for-20162017.html',
    publishedDate => '2016-05-05T14:15:00',
};


Readonly our $HARVESTED_ITEM_1 => {
    title => 'New NVivo Licence for 2016/2017',
    description => "<p><strong>Specialist Software Downloads Now Available Via LEARN.</strong></p>
<p>The new NVivo 2016 / 2017 licence is now available to download via the LEARN system. To download the latest version, please visit\x{a0}<a href=\"http://learn.lboro.ac.uk/course/view.php?id=9766\">http://learn.lboro.ac.uk/course/view.php?id=9766</a></p>
<h4><strong>Other specialist software currently available:</strong></h4>
<p class=\"sectionname\" id=\"yui_3_17_2_3_1462455037496_309\">IBM SPSS Statistics 22</p>
<p class=\"sectionname\" id=\"yui_3_17_2_3_1462455037496_316\">Maplesoft Maple 2015</p>
<p class=\"sectionname\">Siemens PLM NX 8.5.3</p>
<div class=\"content\">
<p class=\"sectionname\">Mindjet MindManager</p>
<p class=\"sectionname\">Granta CES EduPack 2015</p>
<p class=\"sectionname\"><span>National Instruments LabVIEW (Engineering Students Only)</span></p>
<p class=\"sectionname\" id=\"yui_3_17_2_3_1462455037496_327\">OriginLab</p>
<p class=\"sectionname\">Matlab</p>
<p class=\"sectionname\">\x{a0}</p>
<p class=\"sectionname\">IT Services</p>
</div>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/new-nvivo-licence-for-20162017.html',
    publishedDate => '2016-05-05T14:15:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1462457700',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_1 => "New NVivo Licence for 2016/2017 http://www.lboro.ac.uk/services/it/announcements/new-nvivo-licence-for-20162017.html";

Readonly our $TITLE_POST_ITEM_1 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/new-nvivo-licence-for-20162017.html',
    message => "New NVivo Licence for 2016/2017


Specialist Software Downloads Now Available Via LEARN.

The new NVivo 2016 / 2017 licence is now available to download via the LEARN system. To download the latest version, please visit\x{a0}http://learn.lboro.ac.uk/course/view.php?id=9766

Other specialist software currently available:

IBM SPSS Statistics 22

Maplesoft Maple 2015

Siemens PLM NX 8.5.3

Mindjet MindManager

Granta CES EduPack 2015

National Instruments LabVIEW (Engineering Students Only)

OriginLab

Matlab

\x{a0}

IT Services
",
};


Readonly our $ITEM_2 => {
    title => 'Group Workspace Downtime',
    description =>"<p>In late 2015, IT Services initiated a project to address the University\x{2019}s storage needs, improve performance of workspaces and provide capacity for future growth. The project consists of two key phases; firstly, a complete replacement of the existing storage infrastructure with the latest architecture available in the market today, and secondly the migration of virtual servers, group and individual filestore.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>The first phase of works has been completed and the project is now moving into the second phase of works where the migrations will take place.</p>
<p>These migrations will elicit disruption and downtime to both students and staff accessing files and documents from workspaces and filestore during the changeover of services. To ensure this disruption is kept to a minimum, consultation with stakeholders (including School Operations Managers and the Academic Registry) across the institution has taken place to identify the least disruptive dates alongside the decision to conduct these changes overnight.</p>
<p><strong>TIMESCALE?</strong></p>
<p>The planned dates for the migration of workspaces is as follows;</p>
<ul>
<li><span>Group Workspaces:-</span><strong>WS5, WS6, WS7, WS8*</strong></li>
</ul>
<p>Disruptive Period:\x{a0}<strong><span>Thurs 12th May (approx. 18:00hrs) \x{2013} Fri 13th May (approx. 10:00hrs)</span></strong></p>
<p>\x{a0}</p>
<ul>
<li><span>Individual Workspaces:-</span><strong>HS1, HS2, HS3, HS4*</strong></li>
</ul>
<p>Disruptive Period:\x{a0}<strong><span>Thurs 7th July (approx. 18:00hrs) \x{2013} Fri 8th July (approx. 10:00hrs)</span></strong></p>
<p>\x{a0}</p>
<ul>
<li><span>Individual Workspaces:-</span><strong>HS5, HS6, HS7, HS8*</strong></li>
</ul>
<p>Disruptive Period:\x{a0}<strong><span>Thurs 14th July (approx. 18:00hrs) \x{2013} Fri 15th July (approx. 10:00hrs)</span></strong></p>
<p><strong>\x{a0}</strong></p>
<p><span>We appreciate users may need to work on key tasks during this period and advise that anyone working locally applies due diligence and takes the necessary precautions over data security until the completion of these works.</span></p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>For further information and advice on these works, please contact the IT Service Desk via<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}or on extension 222333.</p>
<p>(* WS & HS denominations represent parts of Network File Store as specified above.\x{a0} This storage is sometimes referred to as Individual Workspace, U: drive or Group Workspace. The proposed disruption will affect this storage, including all folders and files found under the \x{201c}Network Location\x{201d} on your computer)<span>\x{a0}</span></p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/group-workspace-downtime.html',
    publishedDate => '2016-04-26T10:08:00',
};

 
Readonly our $HARVESTED_ITEM_2 => {
    title => 'Group Workspace Downtime',
    description =>"<p>In late 2015, IT Services initiated a project to address the University\x{2019}s storage needs, improve performance of workspaces and provide capacity for future growth. The project consists of two key phases; firstly, a complete replacement of the existing storage infrastructure with the latest architecture available in the market today, and secondly the migration of virtual servers, group and individual filestore.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>The first phase of works has been completed and the project is now moving into the second phase of works where the migrations will take place.</p>
<p>These migrations will elicit disruption and downtime to both students and staff accessing files and documents from workspaces and filestore during the changeover of services. To ensure this disruption is kept to a minimum, consultation with stakeholders (including School Operations Managers and the Academic Registry) across the institution has taken place to identify the least disruptive dates alongside the decision to conduct these changes overnight.</p>
<p><strong>TIMESCALE?</strong></p>
<p>The planned dates for the migration of workspaces is as follows;</p>
<ul>
<li><span>Group Workspaces:-</span><strong>WS5, WS6, WS7, WS8*</strong></li>
</ul>
<p>Disruptive Period:\x{a0}<strong><span>Thurs 12th May (approx. 18:00hrs) \x{2013} Fri 13th May (approx. 10:00hrs)</span></strong></p>
<p>\x{a0}</p>
<ul>
<li><span>Individual Workspaces:-</span><strong>HS1, HS2, HS3, HS4*</strong></li>
</ul>
<p>Disruptive Period:\x{a0}<strong><span>Thurs 7th July (approx. 18:00hrs) \x{2013} Fri 8th July (approx. 10:00hrs)</span></strong></p>
<p>\x{a0}</p>
<ul>
<li><span>Individual Workspaces:-</span><strong>HS5, HS6, HS7, HS8*</strong></li>
</ul>
<p>Disruptive Period:\x{a0}<strong><span>Thurs 14th July (approx. 18:00hrs) \x{2013} Fri 15th July (approx. 10:00hrs)</span></strong></p>
<p><strong>\x{a0}</strong></p>
<p><span>We appreciate users may need to work on key tasks during this period and advise that anyone working locally applies due diligence and takes the necessary precautions over data security until the completion of these works.</span></p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>For further information and advice on these works, please contact the IT Service Desk via<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}or on extension 222333.</p>
<p>(* WS & HS denominations represent parts of Network File Store as specified above.\x{a0} This storage is sometimes referred to as Individual Workspace, U: drive or Group Workspace. The proposed disruption will affect this storage, including all folders and files found under the \x{201c}Network Location\x{201d} on your computer)<span>\x{a0}</span></p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/group-workspace-downtime.html',
    publishedDate => '2016-04-26T10:08:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1461665280',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_2 => "Group Workspace Downtime http://www.lboro.ac.uk/services/it/announcements/group-workspace-downtime.html";

Readonly our $TITLE_POST_ITEM_2 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/group-workspace-downtime.html',
    message => "Group Workspace Downtime


In late 2015, IT Services initiated a project to address the University\x{2019}s storage needs, improve performance of workspaces and provide capacity for future growth. The project consists of two key phases; firstly, a complete replacement of the existing storage infrastructure with the latest architecture available in the market today, and secondly the migration of virtual servers, group and individual filestore.

HOW WILL THE WORKS AFFECT ME?

The first phase of works has been completed and the project is now moving into the second phase of works where the migrations will take place.

These migrations will elicit disruption and downtime to both students and staff accessing files and documents from workspaces and filestore during the changeover of services. To ensure this disruption is kept to a minimum, consultation with stakeholders (including School Operations Managers and the Academic Registry) across the institution has taken place to identify the least disruptive dates alongside the decision to conduct these changes overnight.

TIMESCALE?

The planned dates for the migration of workspaces is as follows;

Group Workspaces:-WS5, WS6, WS7, WS8*

Disruptive Period:\x{a0}Thurs 12th May (approx. 18:00hrs) \x{2013} Fri 13th May (approx. 10:00hrs)

\x{a0}

Individual Workspaces:-HS1, HS2, HS3, HS4*

Disruptive Period:\x{a0}Thurs 7th July (approx. 18:00hrs) \x{2013} Fri 8th July (approx. 10:00hrs)

\x{a0}

Individual Workspaces:-HS5, HS6, HS7, HS8*

Disruptive Period:\x{a0}Thurs 14th July (approx. 18:00hrs) \x{2013} Fri 15th July (approx. 10:00hrs)

\x{a0}

We appreciate users may need to work on key tasks during this period and advise that anyone working locally applies due diligence and takes the necessary precautions over data security until the completion of these works.

CAN I GET MORE INFORMATION AND HELP?

For further information and advice on these works, please contact the IT Service Desk viaIT.Services\@lboro.ac.uk\x{a0}or on extension 222333.

(* WS & HS denominations represent parts of Network File Store as specified above.\x{a0} This storage is sometimes referred to as Individual Workspace, U: drive or Group Workspace. The proposed disruption will affect this storage, including all folders and files found under the \x{201c}Network Location\x{201d} on your computer)\x{a0}

IT Services
",
};

Readonly our $ITEM_3 => {
    title => "Staff Mail Archive Decommissioning \x{2013} Outlook 2010 performance
",
    description => "<p>As previously announced by email and via\x{a0}<a href=\"http://www.lboro.ac.uk/internal/news/2016/march/staff-mail-archive-.html\">news</a>, IT Services have decommissioned the Staff Mail Archive service.</p>
<p>We have been made aware of a number of people who have not yet removed the \x{201c}StaffMailArchive\x{201d} additional mailbox from Outlook 2010 (Action 3 in prior announcements) and are subsequently experiencing a degraded experience on their PCs.</p>
<p>Please could you advise people within your area to follow the guidance below to remove the StaffMailArchive from their Outlook profile in order to avoid performance issues:\x{a0}<a href=\"http://kb.umd.edu/128432\">http://kb.umd.edu/128432</a>\x{a0}(external link from the University of Maryland)</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/staff-mail-archive-decommissioning--outlook-2010-performance.html',
    publishedDate => '2016-04-20T15:44:00',
};

 
Readonly our $HARVESTED_ITEM_3 => {
    title => "Staff Mail Archive Decommissioning \x{2013} Outlook 2010 performance
",
    description => "<p>As previously announced by email and via\x{a0}<a href=\"http://www.lboro.ac.uk/internal/news/2016/march/staff-mail-archive-.html\">news</a>, IT Services have decommissioned the Staff Mail Archive service.</p>
<p>We have been made aware of a number of people who have not yet removed the \x{201c}StaffMailArchive\x{201d} additional mailbox from Outlook 2010 (Action 3 in prior announcements) and are subsequently experiencing a degraded experience on their PCs.</p>
<p>Please could you advise people within your area to follow the guidance below to remove the StaffMailArchive from their Outlook profile in order to avoid performance issues:\x{a0}<a href=\"http://kb.umd.edu/128432\">http://kb.umd.edu/128432</a>\x{a0}(external link from the University of Maryland)</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/staff-mail-archive-decommissioning--outlook-2010-performance.html',
    publishedDate => '2016-04-20T15:44:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1461167040',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_3 => "Staff Mail Archive Decommissioning \x{2013} Outlook 2010 performance\nhttp://www.lboro.ac.uk/services/it/announcements/staff-mail-archive-decommissioning--outlook-2010-performance.html";

Readonly our $TITLE_POST_ITEM_3 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/staff-mail-archive-decommissioning--outlook-2010-performance.html',
    message => "",
};


Readonly our $ITEM_4 => {
    title => 'Free Cakes & Coffee up for Grabs!',
    description => "<p>IT Services are looking for volunteers (Student, Professional Services and Academic Staff, Researchers, and University Tenants) to participate in 1.5hr long focus groups to test drive the newly designed IT Services website before its official launch.<br /><br />Focus groups will be taking place on Monday 4th April to Wednesday 6th April in Haslegrave, N004. Refreshments will be provided to all participants. If you are interested in taking part, please email<a href=\"http://www.lboro.ac.uk/services/it/support/announcements/%20Free%20cakes%20&%20coffee%20up%20for%20grabs!\">\x{a0}itscommsteam\@lboro.ac.uk</a>\x{a0}, specifying your availability for dates/times listed below:\x{a0}<br /><br />Monday 4th April AM<br />Monday 4th April PM<br /><br />Tuesday 5th April AM<br />Tuesday 5th April PM<br /><br />Wednesday 6th April AM<br />Wednesday 6th April PM<br /><br />Regards<br />IT Services</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/free-cakes--coffee-up-for-grabs.html',
    publishedDate => '2016-03-18T14:42:00',
};

 
Readonly our $HARVESTED_ITEM_4 => {
    title => 'Free Cakes & Coffee up for Grabs!',
    url => 'http://www.lboro.ac.uk/services/it/announcements/free-cakes--coffee-up-for-grabs.html',
    description => "<p>IT Services are looking for volunteers (Student, Professional Services and Academic Staff, Researchers, and University Tenants) to participate in 1.5hr long focus groups to test drive the newly designed IT Services website before its official launch.<br /><br />Focus groups will be taking place on Monday 4th April to Wednesday 6th April in Haslegrave, N004. Refreshments will be provided to all participants. If you are interested in taking part, please email<a href=\"http://www.lboro.ac.uk/services/it/support/announcements/%20Free%20cakes%20&%20coffee%20up%20for%20grabs!\">\x{a0}itscommsteam\@lboro.ac.uk</a>\x{a0}, specifying your availability for dates/times listed below:\x{a0}<br /><br />Monday 4th April AM<br />Monday 4th April PM<br /><br />Tuesday 5th April AM<br />Tuesday 5th April PM<br /><br />Wednesday 6th April AM<br />Wednesday 6th April PM<br /><br />Regards<br />IT Services</p>
<p>\x{a0}</p>",
    publishedDate => '2016-03-18T14:42:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1458312120',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_4 => "Free Cakes & Coffee up for Grabs! http://www.lboro.ac.uk/services/it/announcements/free-cakes--coffee-up-for-grabs.html";

Readonly our $TITLE_POST_ITEM_4 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/free-cakes--coffee-up-for-grabs.html',
    message => "",
};


Readonly our $ITEM_5 => {
    title => 'SERVICE DISRUPTION: Campus Network Down for Maintenance (Tuesday 23rd February 2016)',
    description => "<p><strong>IMPORTANT</strong></p>
<p>Please be aware that at 07:00 on Tuesday 23rd February 2016 the University's core network will be undergoing maintenance and as such there will be no network availability for an anticipated 30 minute period. \x{a0}The service will remain at risk until approximately 09.00.</p>
<p>During this period the University network will be unavailable affecting all of campus and Halls (including Loughborough in London)</p>
<p>Services affected are:</p>
<ul>
<li>Campus Internet and HallNet</li>
<li>Phone services</li>
<li>eduroam Wi-Fi</li>
<li>Imago Wi-Fi \x{a0}</li>
</ul>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via\x{a0}<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0} or on extension 222333.</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/service-disruption-campus-network-down-for-maintenance-tuesday-23rd-february-2.html',
    publishedDate => '2016-02-17T11:36:00',
};

 
Readonly our $HARVESTED_ITEM_5 => {
    title => 'SERVICE DISRUPTION: Campus Network Down for Maintenance (Tuesday 23rd February 2016)',
    description => "<p><strong>IMPORTANT</strong></p>
<p>Please be aware that at 07:00 on Tuesday 23rd February 2016 the University's core network will be undergoing maintenance and as such there will be no network availability for an anticipated 30 minute period. \x{a0}The service will remain at risk until approximately 09.00.</p>
<p>During this period the University network will be unavailable affecting all of campus and Halls (including Loughborough in London)</p>
<p>Services affected are:</p>
<ul>
<li>Campus Internet and HallNet</li>
<li>Phone services</li>
<li>eduroam Wi-Fi</li>
<li>Imago Wi-Fi \x{a0}</li>
</ul>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via\x{a0}<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0} or on extension 222333.</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/service-disruption-campus-network-down-for-maintenance-tuesday-23rd-february-2.html',
    publishedDate => '2016-02-17T11:36:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1455708960',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_5 => "SERVICE DISRUPTION: Campus Network Down for Maintenance (Tuesday 23rd February 2016) http://www.lboro.ac.uk/services/it/announcements/service-disruption-campus-network-down-for-maintenance-tuesday-23rd-february-2.html";

Readonly our $TITLE_POST_ITEM_5 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/service-disruption-campus-network-down-for-maintenance-tuesday-23rd-february-2.html',
    message => "",
};


Readonly our $ITEM_6 => {
    title => 'HallNet Service Still at Risk',
    description => "<p>HallNet service is still at risk. We are currently experiencing issues with intermittent\x{a0}outages with the networking across Halls of residence. We are working with our the supplier to fully resolve this issue. Further notification will be sent once service has been restored.</p>
<p>We apologise for any inconvenience caused.</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-service-still-at-risk.html',
    publishedDate => '2016-02-09T10:38:00',
};

 
Readonly our $HARVESTED_ITEM_6 => {
    title => 'HallNet Service Still at Risk',
    description => "<p>HallNet service is still at risk. We are currently experiencing issues with intermittent\x{a0}outages with the networking across Halls of residence. We are working with our the supplier to fully resolve this issue. Further notification will be sent once service has been restored.</p>
<p>We apologise for any inconvenience caused.</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-service-still-at-risk.html',
    publishedDate => '2016-02-09T10:38:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1455014280',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_6 => "HallNet Service Still at Risk http://www.lboro.ac.uk/services/it/announcements/hallnet-service-still-at-risk.html";

Readonly our $TITLE_POST_ITEM_6 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-service-still-at-risk.html',
    message => "",
};


Readonly our $ITEM_7 => {
    title => 'HallNet Connection Currently Down',
    description => "<p>Networking in Halls is currently down. IT Services are aware and are currently working on a resolution. Further updates will be provided in due course. We apologise for any inconvenience caused.</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-connection-currently-down.html',
    publishedDate => '2016-02-08T08:39:00',
};

 
Readonly our $HARVESTED_ITEM_7 => {
    title => 'HallNet Connection Currently Down',
    description => "<p>Networking in Halls is currently down. IT Services are aware and are currently working on a resolution. Further updates will be provided in due course. We apologise for any inconvenience caused.</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-connection-currently-down.html',
    publishedDate => '2016-02-08T08:39:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1454920740',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_7 => "HallNet Connection Currently Down http://www.lboro.ac.uk/services/it/announcements/hallnet-connection-currently-down.html";

Readonly our $TITLE_POST_ITEM_7 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-connection-currently-down.html',
    message => "",
};


Readonly our $ITEM_8 => {
    title => 'Remedial work on the storage that underpins Individual and Group Workspace, SCCM and Learn',
    description => "<p>IT Services will be working with Logicalis to address some storage issues on volumes that underpin Individual and Group Workspaces, SCCM 2007 and Learn. This will return the storage infrastructure to its preferred state prior to the exam period next week.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>No outage is anticipated for Individual or Group Workspaces but the following should be considered at risk:</p>
<p>hs2.lboro.ac.uk</p>
<p>hs6.lboro.ac.uk</p>
<p>ws6.lboro.ac.uk</p>
<p>No outage is anticipated for Learn but Archived versions from previous years, plus VLE software downloads should be considered at risk.</p>
<p>As a precautionary measure SCCM will be unavailable until Thursday 7th January around 9am, once completion of the work has been confirmed.</p>
<p><strong>TIMESCALE?</strong></p>
<p>The work will take place Wednesday 6th January from 16:00 to 20:00.</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}\x{a0}or on extension 222333.</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/remedial-work-on-the-storage-that-underpins-individual-and-group-workspace-sccm.html',
    publishedDate => '2016-01-05T10:44:00',
};

 
Readonly our $HARVESTED_ITEM_8 => {
    title => 'Remedial work on the storage that underpins Individual and Group Workspace, SCCM and Learn',
    description => "<p>IT Services will be working with Logicalis to address some storage issues on volumes that underpin Individual and Group Workspaces, SCCM 2007 and Learn. This will return the storage infrastructure to its preferred state prior to the exam period next week.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>No outage is anticipated for Individual or Group Workspaces but the following should be considered at risk:</p>
<p>hs2.lboro.ac.uk</p>
<p>hs6.lboro.ac.uk</p>
<p>ws6.lboro.ac.uk</p>
<p>No outage is anticipated for Learn but Archived versions from previous years, plus VLE software downloads should be considered at risk.</p>
<p>As a precautionary measure SCCM will be unavailable until Thursday 7th January around 9am, once completion of the work has been confirmed.</p>
<p><strong>TIMESCALE?</strong></p>
<p>The work will take place Wednesday 6th January from 16:00 to 20:00.</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}\x{a0}or on extension 222333.</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/remedial-work-on-the-storage-that-underpins-individual-and-group-workspace-sccm.html',
    publishedDate => '2016-01-05T10:44:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1451990640',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_8 => "Remedial work on the storage that underpins Individual and Group Workspace, SCCM and Learn http://www.lboro.ac.uk/services/it/announcements/remedial-work-on-the-storage-that-underpins-individual-and-  group-workspace-sccm.html";

Readonly our $TITLE_POST_ITEM_8 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/remedial-work-on-the-storage-that-underpins-individual-and-group-workspace-sccm.html',
    message => "",
};


Readonly our $ITEM_9 => {
    title => 'Student PC Labs Survey',
    description => "<p>Fancy winning an iPad mini? Have you got 5 minutes to spare?</p>
<p>We need your feedback! IT Services have launched a survey giving students at Loughborough University the opportunity to feedback about the current provision of IT labs on campus. All entries will be automatically added into a free prize draw to win an iPad mini. Please click<a href=\"https://lboro.onlinesurveys.ac.uk/loughborough-university-it-lab-survey-students\">\x{a0}here</a>\x{a0}to complete the online survey.</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/student-pc-labs-survey.html',
    publishedDate => '2016-01-04T10:49:00',
};

 
Readonly our $HARVESTED_ITEM_9 => {
    title => 'Student PC Labs Survey',
    description => "<p>Fancy winning an iPad mini? Have you got 5 minutes to spare?</p>
<p>We need your feedback! IT Services have launched a survey giving students at Loughborough University the opportunity to feedback about the current provision of IT labs on campus. All entries will be automatically added into a free prize draw to win an iPad mini. Please click<a href=\"https://lboro.onlinesurveys.ac.uk/loughborough-university-it-lab-survey-students\">\x{a0}here</a>\x{a0}to complete the online survey.</p>
<p>IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/student-pc-labs-survey.html',
    publishedDate => '2016-01-04T10:49:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1451904540',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_9 => "Student PC Labs Survey http://www.lboro.ac.uk/services/it/announcements/student-pc-labs-survey.html";

Readonly our $TITLE_POST_ITEM_9 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/student-pc-labs-survey.html',
    message => "",
};


Readonly our $ITEM_10 => {
    title => 'Planned Outages: Individual or Group Workspace',
    description => "<p>IT services will be performing maintenance on the University Data Centres to accommodate future expansion of services. The only service that will experience an outage are Individual and Group Workspace, which will experience an outage of between 90 minutes to two hours on the dates below.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>If you are using Individual or Group workspace at the time of the planned outage, then you may lose access at this time so please ensure you have saved and closed files prior to this time.</p>
<p>\x{a0}</p>
<p><strong>TIMESCALE?</strong></p>
<p>There will be an outage on the following dates and times:-</p>
<p><strong>Thursday 17<sup>th</sup>\x{a0}December</strong>\x{a0}\x{2013} from 19:00</p>
<p><strong>Friday 18<sup>th</sup>\x{a0}December</strong>\x{a0}\x{2013} from 07:00</p>
<p>Then one of</p>
<p><strong>Tuesday 22nd December</strong>\x{a0}\x{2013} from 19:00, or</p>
<p><strong>Wednesday 23rd December</strong>\x{a0}\x{2013} from 08:00</p>
<p>\x{a0}</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via\x{a0}<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}\x{a0}or on extension 222333.</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/planned-outages-individual-or-group-workspace.html',
    publishedDate => '2015-12-17T10:54:00',
};

 
Readonly our $HARVESTED_ITEM_10 => {
    title => 'Planned Outages: Individual or Group Workspace',
    description => "<p>IT services will be performing maintenance on the University Data Centres to accommodate future expansion of services. The only service that will experience an outage are Individual and Group Workspace, which will experience an outage of between 90 minutes to two hours on the dates below.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>If you are using Individual or Group workspace at the time of the planned outage, then you may lose access at this time so please ensure you have saved and closed files prior to this time.</p>
<p>\x{a0}</p>
<p><strong>TIMESCALE?</strong></p>
<p>There will be an outage on the following dates and times:-</p>
<p><strong>Thursday 17<sup>th</sup>\x{a0}December</strong>\x{a0}\x{2013} from 19:00</p>
<p><strong>Friday 18<sup>th</sup>\x{a0}December</strong>\x{a0}\x{2013} from 07:00</p>
<p>Then one of</p>
<p><strong>Tuesday 22nd December</strong>\x{a0}\x{2013} from 19:00, or</p>
<p><strong>Wednesday 23rd December</strong>\x{a0}\x{2013} from 08:00</p>
<p>\x{a0}</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via\x{a0}<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}\x{a0}or on extension 222333.</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/planned-outages-individual-or-group-workspace.html',
    publishedDate => '2015-12-17T10:54:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1450349640',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_10 => "Planned Outages: Individual or Group Workspace http://www.lboro.ac.uk/services/it/announcements/planned-outages-individual-or-group-workspace.html";

Readonly our $TITLE_POST_ITEM_10 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/planned-outages-individual-or-group-workspace.html',
    message => "",
};


Readonly our $ITEM_11 => {
    title => 'IT Services Availability During Christmas / New Year Period',
    description => "<p>The University will close for Christmas on the afternoon of Wednesday 23<sup>rd</sup>\x{a0}December 2015 and will re-open on Monday 4th January 2016.<span class=\"apple-converted-space\">\x{a0}</span><br /><br />During this holiday period all of the labs which have 24 hour access, will remain open this year.</p>
<p>Click here for the\x{a0}<a href=\"http://www.lboro.ac.uk/services/it/labs/labs/\">location</a>\x{a0}of these labs.</p>
<p>You will need your student ID card in order to access the buildings.<br /><br />The PC Clinic located in the library will close at 3pm on Wednesday 23<sup>rd</sup>\x{a0}December 2015 and will re-open on Monday 4th January 2016.<span class=\"apple-converted-space\">\x{a0}</span></p>
<p>The IT Service Desk will close on the afternoon of Wednesday 23<sup>rd</sup>\x{a0}December 2015 and will re-open on Monday 4th January 2016.<span class=\"apple-converted-space\">\x{a0}</span><br /><br />Merry Christmas and a Happy New Year<br /><br />IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/it-services-availability-during-christmas--new-year-period.html',
    publishedDate => '2015-12-10T13:59:00',
};

 
Readonly our $HARVESTED_ITEM_11 => {
    title => 'IT Services Availability During Christmas / New Year Period',
    description => "<p>The University will close for Christmas on the afternoon of Wednesday 23<sup>rd</sup>\x{a0}December 2015 and will re-open on Monday 4th January 2016.<span class=\"apple-converted-space\">\x{a0}</span><br /><br />During this holiday period all of the labs which have 24 hour access, will remain open this year.</p>
<p>Click here for the\x{a0}<a href=\"http://www.lboro.ac.uk/services/it/labs/labs/\">location</a>\x{a0}of these labs.</p>
<p>You will need your student ID card in order to access the buildings.<br /><br />The PC Clinic located in the library will close at 3pm on Wednesday 23<sup>rd</sup>\x{a0}December 2015 and will re-open on Monday 4th January 2016.<span class=\"apple-converted-space\">\x{a0}</span></p>
<p>The IT Service Desk will close on the afternoon of Wednesday 23<sup>rd</sup>\x{a0}December 2015 and will re-open on Monday 4th January 2016.<span class=\"apple-converted-space\">\x{a0}</span><br /><br />Merry Christmas and a Happy New Year<br /><br />IT Services</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/it-services-availability-during-christmas--new-year-period.html',
    publishedDate => '2015-12-10T13:59:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1449755940',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_11 => "IT Services Availability During Christmas / New Year Period http://www.lboro.ac.uk/services/it/announcements/it-services-availability-during-christmas--new-year-period.html";

Readonly our $TITLE_POST_ITEM_11 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/it-services-availability-during-christmas--new-year-period.html',
    message => "",
};


Readonly our $ITEM_12 => {
    title => 'HallNet Service Customer Survey 2015',
    description => "<p><strong>Help us improve the HallNet Service and win a \x{a3}25 Voucher!!</strong></p>
<p>This is an invitation to all students and users of the HallNet Service to complete the customer satisfaction online survey.</p>
<p>Have you had a good or bad experience with this service? We would really like to hear from you, your feedback will help IT Services to improve the service you receive!\x{a0}</p>
<p><a href=\"https://lboro.onlinesurveys.ac.uk/hallnet-survey-dec-2015\">Click here</a>\x{a0}to access the survey.</p>
<p>All replies will be entered into a prize draw for free \x{a3}25 Tesco voucher.</p>
<p>Thank you for your time. \x{a0}</p>
<p><strong>If you need more help?</strong></p>
<p>If you have any questions, please contact the IT Service Desk via\x{a0}<a href=\"mailto:it.services\@lboro.ac.uk\">it.services\@lboro.ac.uk</a>\x{a0}</p>
<p>\x{a0}</p>
<p>IT Services</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-service-customer-survey-2015.html',
    publishedDate => '2015-12-09T15:01:00',
};

 
Readonly our $HARVESTED_ITEM_12 => {
    title => 'HallNet Service Customer Survey 2015',
    description => "<p><strong>Help us improve the HallNet Service and win a \x{a3}25 Voucher!!</strong></p>
<p>This is an invitation to all students and users of the HallNet Service to complete the customer satisfaction online survey.</p>
<p>Have you had a good or bad experience with this service? We would really like to hear from you, your feedback will help IT Services to improve the service you receive!\x{a0}</p>
<p><a href=\"https://lboro.onlinesurveys.ac.uk/hallnet-survey-dec-2015\">Click here</a>\x{a0}to access the survey.</p>
<p>All replies will be entered into a prize draw for free \x{a3}25 Tesco voucher.</p>
<p>Thank you for your time. \x{a0}</p>
<p><strong>If you need more help?</strong></p>
<p>If you have any questions, please contact the IT Service Desk via\x{a0}<a href=\"mailto:it.services\@lboro.ac.uk\">it.services\@lboro.ac.uk</a>\x{a0}</p>
<p>\x{a0}</p>
<p>IT Services</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-service-customer-survey-2015.html',
    publishedDate => '2015-12-09T15:01:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1449673260',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_12 => "HallNet Service Customer Survey 2015 http://www.lboro.ac.uk/services/it/announcements/hallnet-service-customer-survey-2015.html";

Readonly our $TITLE_POST_ITEM_12 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/hallnet-service-customer-survey-2015.html',
    message => "",
};


Readonly our $ITEM_13 => {
    title => "Intermittent Connectivity \x{2013} JISC Outages",
    description => "<p>Our internet connection provider, JISC,\x{a0} is suffering from a significant problem with connectivity which is affecting all UK Universities.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>The effect on Loughborough University is that several of our externally hosted services are intermittently unavailable. This includes, but is not limited to:</p>
<ul>
<li>Office 365 Email</li>
<li>Google Apps for Students and Staff</li>
</ul>
<p>General internet access is also affected; some websites may also be intermittently unavailable.</p>
<p><strong>TIMESCALE?</strong></p>
<p>This issue is outside IT Services' control and is being dealt with by our internet connection provider as their highest priority.</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0} or on extension 222333.</p>
<div align=\"center\">\x{a0}</div>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/intermittent-connectivity--jisc-outages.html',
    publishedDate => '2015-12-08T10:09:00',
};

 
Readonly our $HARVESTED_ITEM_13 => {
    title => "Intermittent Connectivity \x{2013} JISC Outages",
    description => "<p>Our internet connection provider, JISC,\x{a0} is suffering from a significant problem with connectivity which is affecting all UK Universities.</p>
<p><strong>HOW WILL THE WORKS AFFECT ME?</strong></p>
<p>The effect on Loughborough University is that several of our externally hosted services are intermittently unavailable. This includes, but is not limited to:</p>
<ul>
<li>Office 365 Email</li>
<li>Google Apps for Students and Staff</li>
</ul>
<p>General internet access is also affected; some websites may also be intermittently unavailable.</p>
<p><strong>TIMESCALE?</strong></p>
<p>This issue is outside IT Services' control and is being dealt with by our internet connection provider as their highest priority.</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0} or on extension 222333.</p>
<div align=\"center\">\x{a0}</div>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/intermittent-connectivity--jisc-outages.html',
    publishedDate => '2015-12-08T10:09:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1449569340',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_13 => "Intermittent Connectivity \x{2013} JISC Outages http://www.lboro.ac.uk/services/it/announcements/intermittent-connectivity--jisc-outages.html";

Readonly our $TITLE_POST_ITEM_13 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/intermittent-connectivity--jisc-outages.html',
    message => "",
};



Readonly our $ITEM_14 => {
    title => 'Future Cloud Office Platform',
    description => "<p><span>IT Services completed a successful deployment of the Microsoft Office 365 email platform to staff in Spring 2015. This transition has provided a sound foundation to consolidate and unify a number of existing IT systems which are becoming less effective, with a requirement to replace them with modern, fit for purpose Cloud office environment.</span></p>
<p><span>In November 2015, IT Services hosted an event inviting staff and students to a presentation and open discussion. The event outlined how IT Services propose to consolidate services to the Microsoft Office 365 platform \x{2013} a supported platform for productivity and communication for both staff and students.</span></p>
<p><span>To provide a direct feedback opportunity, a series of meetings have been held with key stakeholders and the proposal has been presented at a number of committees.</span></p>
<p><span>Microsoft Office 365 has many benefits, these include:</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Unlimited file store using Microsoft OneDrive;</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Web based access to Word, Excel, PowerPoint and other Microsoft Office from any device \x{2013} reducing the need for filePort, VPN, USB sticks, Dropbox, duplication of files etc.;</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Rich collaboration tools for both staff and student;</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Easy access to free Microsoft software for student and for staff home use.</span></p>
<p><span>As this new platform is implemented, Google Apps for Education will be classified as a legacy service will be phased out in an appropriate timescale. The majority of UK HEIs are now providing Microsoft Office 365 series to their organisations.</span></p>
<p><span>For further information on strategy briefing paper and IT event presentation, please visit\x{a0}</span><a href=\"file://ws4.lboro.ac.uk/ITS-TechForum/18.%20November%202015%20-%20Future%20Cloud%20Office%20Platform\"><span>here</span></a><span>.</span></p>
<p><span>If you would like to provide feedback or raise any questions relating to the above, please click\x{a0}</span><a href=\"https://lboro.onlinesurveys.ac.uk/future-cloud-office-platform\"><span>here</span></a><span>.</span></p>
<p><span>Following the close of the consultation period on Friday 11<sup>th</sup>\x{a0}December 2015, all feedback will be considered and a formal project proposal raised at the University wide IT Portfolio Board for consideration.</span></p>
<p><span>\x{a0}</span></p>
<p><span>IT Services</span></p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/future-cloud-office-platform.html',
    publishedDate => '2015-12-01T11:29:00',
};

 
Readonly our $HARVESTED_ITEM_14 => {
    title => 'Future Cloud Office Platform',
    description => "<p><span>IT Services completed a successful deployment of the Microsoft Office 365 email platform to staff in Spring 2015. This transition has provided a sound foundation to consolidate and unify a number of existing IT systems which are becoming less effective, with a requirement to replace them with modern, fit for purpose Cloud office environment.</span></p>
<p><span>In November 2015, IT Services hosted an event inviting staff and students to a presentation and open discussion. The event outlined how IT Services propose to consolidate services to the Microsoft Office 365 platform \x{2013} a supported platform for productivity and communication for both staff and students.</span></p>
<p><span>To provide a direct feedback opportunity, a series of meetings have been held with key stakeholders and the proposal has been presented at a number of committees.</span></p>
<p><span>Microsoft Office 365 has many benefits, these include:</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Unlimited file store using Microsoft OneDrive;</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Web based access to Word, Excel, PowerPoint and other Microsoft Office from any device \x{2013} reducing the need for filePort, VPN, USB sticks, Dropbox, duplication of files etc.;</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Rich collaboration tools for both staff and student;</span></p>
<p><span>\x{b7}<span>\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}\x{a0}</span></span><span>Easy access to free Microsoft software for student and for staff home use.</span></p>
<p><span>As this new platform is implemented, Google Apps for Education will be classified as a legacy service will be phased out in an appropriate timescale. The majority of UK HEIs are now providing Microsoft Office 365 series to their organisations.</span></p>
<p><span>For further information on strategy briefing paper and IT event presentation, please visit\x{a0}</span><a href=\"file://ws4.lboro.ac.uk/ITS-TechForum/18.%20November%202015%20-%20Future%20Cloud%20Office%20Platform\"><span>here</span></a><span>.</span></p>
<p><span>If you would like to provide feedback or raise any questions relating to the above, please click\x{a0}</span><a href=\"https://lboro.onlinesurveys.ac.uk/future-cloud-office-platform\"><span>here</span></a><span>.</span></p>
<p><span>Following the close of the consultation period on Friday 11<sup>th</sup>\x{a0}December 2015, all feedback will be considered and a formal project proposal raised at the University wide IT Portfolio Board for consideration.</span></p>
<p><span>\x{a0}</span></p>
<p><span>IT Services</span></p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/future-cloud-office-platform.html',
    publishedDate => '2015-12-01T11:29:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1448969340',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_14 => "Future Cloud Office Platform http://www.lboro.ac.uk/services/it/announcements/future-cloud-office-platform.html";

Readonly our $TITLE_POST_ITEM_14 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/future-cloud-office-platform.html',
    message => "",
};


Readonly our $ITEM_15 => {
    title => 'Students Required for Focus Group',
    description => "<h4>Volunteers required for focus groups w/c 7th December 2015</h4>
<p>Join us for\x{a0}cake, refreshments and a natter! All participants receive \x{a3}20 print credits. \x{a0}</p>
<p>IT Services are looking for student volunteers to take part in two separate focus groups. The first focus group being held on Tuesday 8th December, will be looking at the move from Google Apps for Education to Office 365 for students, which is part of a larger Office 365 project.</p>
<p>The second focus group taking place on Wednesday 9th December is looking at the current PC Labs provision on campus.</p>
<p>If you are free to volunteer for either focus group or both! Please email the Student Experience & Communications team\x{a0}<a href=\"mailto:itscommsteam\@lboro.ac.uk\">itscommsteam\@lboro.ac.uk</a>\x{a0}confirming your name, student number, contact number and preferred focus group.</p>
<p>For your attendance and valuable input, we will credit your print account with \x{a3}20.00 in Printer Credit.</p>
<p>\x{a0}</p>
<p><strong>Focus Group 1 - O365</strong></p>
<p>Tuesday 8th December 2015 between 10am and 11.30am</p>
<p><strong>Where</strong></p>
<p>Campus location to be confirmed</p>
<p>\x{a0}</p>
<p><strong>Focus Group 2 \x{a0} - Labs Review\x{a0}</strong></p>
<p>Wednesday 9th December 2015 between 10am and 11.30am</p>
<p><strong>Where</strong></p>
<p>Campus location to be confirmed</p>
<p>\x{a0}</p>
<p>IT Services</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/students-required-for-focus-group.html',
    publishedDate => '2015-12-01T11:10:00',
};
 
Readonly our $HARVESTED_ITEM_15 => {
    title => 'Students Required for Focus Group',
    description => "<h4>Volunteers required for focus groups w/c 7th December 2015</h4>
<p>Join us for\x{a0}cake, refreshments and a natter! All participants receive \x{a3}20 print credits. \x{a0}</p>
<p>IT Services are looking for student volunteers to take part in two separate focus groups. The first focus group being held on Tuesday 8th December, will be looking at the move from Google Apps for Education to Office 365 for students, which is part of a larger Office 365 project.</p>
<p>The second focus group taking place on Wednesday 9th December is looking at the current PC Labs provision on campus.</p>
<p>If you are free to volunteer for either focus group or both! Please email the Student Experience & Communications team\x{a0}<a href=\"mailto:itscommsteam\@lboro.ac.uk\">itscommsteam\@lboro.ac.uk</a>\x{a0}confirming your name, student number, contact number and preferred focus group.</p>
<p>For your attendance and valuable input, we will credit your print account with \x{a3}20.00 in Printer Credit.</p>
<p>\x{a0}</p>
<p><strong>Focus Group 1 - O365</strong></p>
<p>Tuesday 8th December 2015 between 10am and 11.30am</p>
<p><strong>Where</strong></p>
<p>Campus location to be confirmed</p>
<p>\x{a0}</p>
<p><strong>Focus Group 2 \x{a0} - Labs Review\x{a0}</strong></p>
<p>Wednesday 9th December 2015 between 10am and 11.30am</p>
<p><strong>Where</strong></p>
<p>Campus location to be confirmed</p>
<p>\x{a0}</p>
<p>IT Services</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/students-required-for-focus-group.html',
    publishedDate => '2015-12-01T11:10:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1448968200',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_15 => "Students Required for Focus Group http://www.lboro.ac.uk/services/it/announcements/students-required-for-focus-group.html";

Readonly our $TITLE_POST_ITEM_15 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/students-required-for-focus-group.html',
    message => "Students Required for Focus Group


Volunteers required for focus groups w/c 7th December 2015

Join us for\x{a0}cake, refreshments and a natter! All participants receive \x{a3}20 print credits. \x{a0}

IT Services are looking for student volunteers to take part in two separate focus groups. The first focus group being held on Tuesday 8th December, will be looking at the move from Google Apps for Education to Office 365 for students, which is part of a larger Office 365 project.

The second focus group taking place on Wednesday 9th December is looking at the current PC Labs provision on campus.

If you are free to volunteer for either focus group or both! Please email the Student Experience & Communications team\x{a0}<a href=\"mailto:itscommsteam\@lboro.ac.uk\">itscommsteam\@lboro.ac.uk</a>\x{a0}confirming your name, student number, contact number and preferred focus group.

For your attendance and valuable input, we will credit your print account with \x{a3}20.00 in Printer Credit.

\x{a0}

Focus Group 1 - O365

Tuesday 8th December 2015 between 10am and 11.30am

Where

Campus location to be confirmed

\x{a0}

Focus Group 2 \x{a0} - Labs Review\x{a0}

Wednesday 9th December 2015 between 10am and 11.30am

Where

Campus location to be confirmed

\x{a0}

IT Services

\x{a0}
",
};


Readonly our $ITEM_16 => {
    title => 'Policy update:Loughborough University Computer Purchasing and Deployment Policy',
    description => "<p><strong>Policy Update</strong></p>
<p>IT Governance Committee have recently approved an updated \x{2018}University Desktop and Laptop Policy\x{2019}.</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>You can find the updated policy on the IT Services website by following the below link:</p>
<p><a href=\"http://www.lboro.ac.uk/it/about/policies/purchasingpolicy/\">www.lboro.ac.uk/it/about/policies/purchasingpolicy/</a></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via\x{a0}<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}\x{a0}\x{a0}or on extension 222333.</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/policy-update-loughborough-university-computer-purchasing-and-deployment-policy.html',
    publishedDate => '2015-11-30T12:18:00',
};

Readonly our $HARVESTED_ITEM_16 => {
    title => 'Policy update:Loughborough University Computer Purchasing and Deployment Policy',
    description => "<p><strong>Policy Update</strong></p>
<p>IT Governance Committee have recently approved an updated \x{2018}University Desktop and Laptop Policy\x{2019}.</p>
<p><strong>CAN I GET MORE INFORMATION AND HELP?</strong></p>
<p>You can find the updated policy on the IT Services website by following the below link:</p>
<p><a href=\"http://www.lboro.ac.uk/it/about/policies/purchasingpolicy/\">www.lboro.ac.uk/it/about/policies/purchasingpolicy/</a></p>
<p>If you have any queries regarding this, please contact the IT Service Desk via\x{a0}<a href=\"mailto:IT.Services\@lboro.ac.uk\">IT.Services\@lboro.ac.uk</a>\x{a0}\x{a0}\x{a0}or on extension 222333.</p>
<p>\x{a0}</p>",
    url => 'http://www.lboro.ac.uk/services/it/announcements/policy-update-loughborough-university-computer-purchasing-and-deployment-policy.html',
    publishedDate => '2015-11-30T12:18:00',
    type => ['Feed Entry'],
    timestamps => {},
    statuses => {},
    rssId => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml#1448885880',
    source => 'http://www.lboro.ac.uk/services/it/announcements/rss/index.xml',
};

Readonly our $TITLE_TWEET_ITEM_16 => "Policy update:Loughborough University Computer Purchasing and Deployment Policy http://www.lboro.ac.uk/services/it/announcements/policy-update-loughborough-university-computer-purchasing-and-deployment-policy.html";

Readonly our $TITLE_POST_ITEM_16 => {
    link => 'http://www.lboro.ac.uk/services/it/announcements/policy-update-loughborough-university-computer-purchasing-and-deployment-policy.html',
    message => "Policy update:Loughborough University Computer Purchasing and Deployment Policy

Policy Update
IT Governance Committee have recently approved an updated \x{2018}University Desktop and Laptop Policy\x{2019}.

CAN I GET MORE INFORMATION AND HELP?

You can find the updated policy on the IT Services website by following the below link:

www.lboro.ac.uk/it/about/policies/purchasingpolicy/

If you have any queries regarding this, please contact the IT Service Desk via\x{a0}IT.Services\@lboro.ac.uk\x{a0}\x{a0}\x{a0}or on extension 222333.

\x{a0}
",

};

1;
