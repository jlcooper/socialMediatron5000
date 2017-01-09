#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/projects/socialMediatron5000/lib';

use CGI;
use Facebook::OpenGraph;

use Settings qw(%FACEBOOK_SETTINGS);

my $cgi = CGI->new();

my $facebook = Facebook::OpenGraph->new({
    app_id => $FACEBOOK_SETTINGS{appId},
    secret => $FACEBOOK_SETTINGS{secret},
    namespace => $FACEBOOK_SETTINGS{namespace},
    redirect_uri => $ENV{SCRIPT_URI},
});

my $code = $cgi->param('code');

if (!$code) {
    my $authUrl = $facebook->auth_uri({
        scope => [qw/manage_pages publish_pages/],
    });
    print $cgi->redirect($authUrl);

} else {
    my $userToken = $facebook->get_user_token_by_code($code);
    $facebook->set_access_token($userToken->{access_token});

    my $pages = $facebook->get('/me/accounts');

    use Data::Dumper;

    my $X=Dumper($pages);
    print <<EOHTML;
content-type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
    <head>
        <style>
            table {
                table-layout: fixed;
                width: 90%;
                margin-left: auto;
                margin-right: auto;

            }
            th, td {
                word-wrap:break-word;
            }
        </style>
    </head>
    <body>
        <p>User Access Token<br>$userToken->{access_token}<br>$userToken->{expires}</p>
        <table>
            <thead>
                <tr><th>Page Name</th><th>Page Id</td><th>Access Token</th></tr>
            </thead>
            <body>
EOHTML

foreach my $page (@{$pages->{data}}) {
    print "                <tr><td>$page->{name}</td><td>$page->{id}</td><td>$page->{access_token}</td></tr>\n";

    my $photos = $facebook->get($page->{id} . "/photos");
    print "<pre>" . Dumper($photos) . "</pre>";
}

print <<EOHTML;
            </body>
        </table>
    </body>
</html>
EOHTML
}

