# Social Mediatron 5000

## Synopsis
The Social Mediatron 5000 harvest details from a number of sources (currently Figshare for Institutions,
DSpace and RSS) and publishes selected details to specified social media sites (currently Twitter and
Facebook). It can also send users a regular digest of new details that have been harvested.

## Requirements
The following are required for running the Social Mediatron 5000:

* MongoDB
* Perl (with the following Perl modules):
    - MongoDB
    - MongoDB::OID;
    - Readonly
    - CGI
    - Carp
    - Class::Std
    - DateTime
    - DateTime::Format::DateParse
    - Facebook::OpenGraph
    - HTML::Entities
    - List::MoreUtils
    - LWP::Simple;
    - Net::Twitter;
    - Try::Tiny;
    - URI::Escape;
    - XML::Simple;
* Web server (Apache is known to work)

## Installation and configuration
The social mediatron 5000 consists of two parts the back-end engine that harvests data,
aggregates it and then publishes it, and the web interface that administrators use to
configure harvesting and publishing agents.

### Back-end engine
The back-end consists of a MongoDB database, the socialMediatron5000 script and a number of
CGI scripts used by the front-end.

#### Load MongoDB's database with the schema
To create the Mongo databhase using the default name of 'socialMediatron5000 then simply run:

`mongo < schema/mongoSchema.js` 

#### Configure lib paths
The following files will need their `use lib` paths updating to reflect the location of the project.

* socialMediatron5000
* cgi-bin/getTweetLog.cgi
* cgi-bin/saveConfiguration.cgi
* cgi-bin/getHarvestingAgents.cgi
* cgi-bin/getPostLog.cgi
* cgi-bin/getFacebookAccessToken.cgi
* cgi-bin/getPublishingAgents.cgi
* lib/TwitterBot.pm
* scripts/getAccessTokens.pl

change the '/usr/local/projects/socialMediatron5000/' part of the `use lib` lines match the path
of where you're hosting your instance.

#### Configure Settings.pm
Copy the lib/SettingsTemplate.pm file to be lib/Settings.pm and then edit it based upon the comments.

#### Test socialMediatron5000 and set it to run regularly
Manually run the socialMediatron5000 script and check it runs OK.  If it does run fine then add
it to your crontab to run at whatever period of granularity you would like (Note that this is the
granularity is how often it will check which of it's harvesting and publishing agents need running,
not how often it will harvest and publish things).

### Front-end web interface
The front-end administration interface is a web application and so you'll need to configure your web server
to run the HTML and CGI scripts.

#### Configure web server
Configure your web server to secure the html directory (/socialMediatron5000) and the cgi-bin directory
(/cgi-bin/socialMediatron5000) with your preferred method of security (BasicAuth, Kerberos, Shibboleth, etc.) -
Only administrators need access to these directories!

You really have two options for making the web app part of the socialMediatron5000 available through
the web server

1. Symbolic links
Create a symbolic link in your web server's html root to the html directory of the project and in the
web server's cgi-bin directory to the project's cgi-bin directory (make sure to
call the symbolic links socialMediatron5000). E.g.

    ln -s /usr/local/projects/socialMediatron5000/html /var/www/html/socialMediatron5000
    ln -s /usr/local/projects/socialMediatron5000/cgi-bin /var/www/cgi-bin/socialMediatron5000

If you're using this method then you'll need to make sure that your web server is configured to follow symlinks.

2. Copying
Copy the html and cgi-bin directories out of the project into your web servers html and cgi-bin directories.
E.g.

    sudo cp -r /usr/local/projects/socialMediatron5000/html /var/www/html/socialMediatron5000
    sudo cp -r /usr/local/projects/socialMediatron5000/cgi-bin /var/www/cgi-bin/socialMediatron5000


## Usage
To be of use the socialMediatron5000 needs to have at least one harvesting agent and one publishing
agent. Harvesting agents available are :

* Figshare
* DSpace
* RSS

Publishing agents available are:

* Twitter
* Email
* Facebook

### Adding a new harvesting agent
To add a new harvesting agent through the web interface select the Harvesting Agents tab and then click on
the '+' icon at the top right.  This will bring up a dialog for you to select the new type of harvesting agent
that wish to add.

Once you've selected the type of harvesting agent then you'll be presented with another dialog to configure
your new harvesting agent.

### Editing an existing harvesting agent
To edit an existing harvesting agent then go to the Harvesting Agents tab and then click on the agent in the
list that you want to edit the settings for. This will bring up a dialog of the agents settings for editing.

### Adding a new publishing agent
To add a new publishing agent select the Publishing Agents tab and then click on the '+' icon in the top
right. This will bring up a dialog for you to select the new type of publishing agent that you wish to add.

Once you've selected the type of publishing agent then you'll be presented with another dialog to configure
your new publishing agent.

### Editing an existing publishing agent
To edit and existing publishing agent go to the Publishing Agents tab and then click on the agent in the
list that you want to edit the settings for. This will bring up a a dialog for you to edit the agents settings
from.

### Viewing the tweet log and Facebook post log
The tweet log can be viewed under the Tweets tab and the Facebook posts log can be viewed under the Facebook
Posts tab.

## Agent configurations
Each agent has a number of configuration fields that control how it will act.  

### Common fields

Title
: this the title of the agent

Harvest items published since
: this field is usually maintained by the harvesting agent itself, but you may need to adjust this if you need
to re-harvest items for some reason

Minimum seconds between harvests
: the minimum number of seconds that must have passed since the last harvest before the agent will
harvest again

Publication types
: a semi-colon delimited list of publication types that you wish the agent to publish

Sources
: a semi-colon delimited list of sources that you wish the agent to publish items from

Sets
: a semi-colon delimited list of sets that you wish the agent to publish items from

Field order
: a semi-colon delimited list of the field names in the order that wish then to appear
e.g. 'title;url;doi'

Active
: this is whether the agent is currently active or not

### DSpace (harvesting)

OAIPMH Base URL
: the base URL of the OAIPMH service on the DSpace repository

Black List
: this field is a regular expression to match collections that you don't want harvest e.g. '(closed|confidential)'

White List
: if present this field is a regular expression to match collections that you do want harvested e.g. '(public|open)'

Item Types
: a semi-colon delimited list of item types that you want to harvest e.g. 'Article;Conference Contribution'

### Figshare (harvesting)

API URL
: the URL of Figshare for institution's API

Institution ID
: the id of the institution that you wish to harvest new items for

### RSS (harvesting)

RSS Feed URL
: the URL of the RSS feed to be harvested

### Twitter (publishing)

Hashtags
: a semi-colon delimited list of hashtags to be made available as the hashtags field

Field to shortened to fit
: if a tweet will be too long then this is the field to be shortened to reduce the tweet's size below 140 characters

Minimum wait between making any tweets (seconds)
: the number of seconds that must have passed since the last tweet before the twitter agent will make another tweet

Make "ICYMI" posts
: if this option is enabled then when there are no new tweets to be made the twitter agent will make an ICYMI tweet

Minimum wait before sending ICYMI tweets (seconds)
: the number of seconds that must have past since the original tweet was made before an ICYMI tweet can be made

Consumer key
: the consumer key that you got when you registered your application with twitter

Consumer secret
: the consumer secret that you got when you registered your application with twitter

Access token
: the access token for tweeting as the account you're connecting to this twitter agent

Access token secret
: the access token secret for tweeting as the account you're connecting to this twitter agent

To get the access token and it's secret you can use the getAccessTokens.pl script in the scripts directory.

### Facebook (publishing)

Link field
: the field to use for adding as a link to the post

Image URL
: the URL for the image to use for the post

Minimum wait between posting to page (seconds)
: the minimum number of seconds possible between the agent making posts

Page ID
: the ID of the page to post to

Page access token
: the access token for the page to post to

The Page ID and Page access token can be got by using the getFacebookAccessToken.cgi cgi script.

### Email (publishing)

Minimum wait between sending Digest Email (seconds)
: the minimum time after sending an email that the agent will send the next email

Address to send email as
: the email address to send the digest email from

Address to send digest email to
: the email address to send the digest email to

Subject of digest email
: the subject line of the email to be sent

Email header
: any text you wish to appear before the list of items in the email body

Email footer
: any text you wish to appear after the list of items in the email body


## License
This project is made available under a MIT License (please see the LICENSE file for more details)
