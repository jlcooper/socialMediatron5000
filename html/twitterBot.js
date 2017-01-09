
/*global $ */

function TwitterBotDashboard() {
    "use strict";
    var API_URL = "/cgi-bin/socailMediatron5000/",
        TEMPLATES_URL = "templates/",
        validPages = {
            'harvesters': harvestersPage,
            'publishers': publishersPage,
            'tweets': tweetsPage,
            'posts': postsPage
        },
        agentTypes = callApi('getAgentTypes.cgi');

    

    this.run = function () {
        $(window).on('hashchange', function () {
            var hashVal,
                path,
                page;

            hashVal = location.hash.replace(/^#/, "");
            hashVal = decodeURIComponent(hashVal);
            path = hashVal.split(/\//);
            if (!path.length || !validPages[path[0]]) {
                path = ['harvesters'];
            }
            page = path.shift();
            $('#mainMenu').removeClass();
            $('#mainMenu').addClass(page);
            $('#mainPage').load(TEMPLATES_URL + page + ".html", function () {
                validPages[page](path);
            });
        }).trigger('hashchange');
    };

    this.addNewAgent = function (agentType) {
        agentTypes.then(function (agentTypes) {
            if (!agentTypes[agentType]) {
                throw "unknown agent type";
            }

            selectAgent(agentType).then( function (agent) {
                $('#popupContent').html(generateAgentConfigurationForm(agent));

                $('#popupCancelButton')
                    .off('click')
                    .click(hidePopup);

                $('#popupSaveButton')
                    .off('click')
                    .click(saveAgent);

                showPopup();
            });
        });
    };

    function editAgent(agent) {
        agentTypes.then(function (agentTypes) {
            var field,
                value,
                element,
                agentGroup,
                input;

            for (agentGroup in agentTypes) {
                if (agentTypes.hasOwnProperty(agentGroup)) {
                    agentTypes[agentGroup].forEach(function (agentType) {  // jshint ignore:line
                        if (agentType.agent == agent.agent) {
                            $('#popupContent').html(generateAgentConfigurationForm(agentType));
                        }
                    });
                }
            }

            $('#popupCancelButton')
                .off('click')
                .click(hidePopup);

            $('#popupSaveButton')
                .off('click')
                .click(saveAgent);

            showPopup();

            for (field in agent) {
                if (agent.hasOwnProperty(field)) {
                    value = agent[field];
                    if ($.isArray(value)) {
                        value = value.join(';');
                    } else if (field == '_id') {
                        value = value.$oid;
                    }

                    input = $('#' + field);

                    if (input.attr('type') == "checkbox") {
                        input.prop('checked', value);
                    } else {
                        input.val(value);
                    }
                }
            }
        });
    }

    function showPopup() {
        $('#popupFuzz').show();
        $('#popupContent').show();
    }

    function hidePopup() {
        $('#popupFuzz').hide();
        $('#popupContent').hide();
    }

    function selectAgent(agentType) {
        return new Promise(function (resolve, reject) {
            agentTypes.then(function (agentTypes) {
                var availableAgents = agentTypes[agentType],
                    html;

                if (availableAgents.length == 1) {
                    resolve(availableAgents[0]);
                } else if (availableAgents.length > 1) {
                    html = '<div id="availableAgents">';
                    availableAgents.forEach(function (agent) {
                        html += '<div class="agentMenu" id="' + agent.agent + '">' + agent.agent + '</div>';
                    });
                    html += '</div>';

                    $('#popupContent').html(html);

                    availableAgents.forEach(function (agent) {
                        $('#' + agent.agent).click(function () {
                            hidePopup();
                            resolve(agent);
                        });
                    });

                    showPopup();
                } else {
                    reject("No agent types available");
                }
            });
        });
    }

    function generateAgentConfigurationForm(agent) {
        var html = '',
            field,
            fieldName,
            configurationFields = agent.fields,
            orderedFields = [];

        html += '<div id="agentType">' + agent.agent + '</div>';
        html += '<div id="configurationFields">';
        html += '<input type="hidden" id="_id">';

        for (fieldName in configurationFields) {
            if (configurationFields.hasOwnProperty(fieldName)) {
                field = configurationFields[fieldName];
                field.name =  fieldName;

                orderedFields.push(field);
            }
        }

        orderedFields.sort(function (a, b) { return (a.order || 0) - (b.order || 0); });

        orderedFields.forEach(function (field) {
            if (field.type != "hidden") {
                html += '<div class="configurationField">';
                html += '<label for="' + field.name + '" id="label_' + field.name+ '">' + field.label + '</label>';
            }

            switch (field.type) {
                case 'textarea':
                    html += '<textarea id="' + field.name +'">' + (field.value || '') +'</textarea>';
                    break;

                default:
                    html += '<input type="'+ field.type +'" id="' + field.name +'" value="' + (field.value || '') +'">';
                    break;
            }

            if (field.type != "hidden") {
                html += '</div>';
            }
        });

        html += '</div>';
        html += '<div class="options"><input type="button" class="negative" id="popupCancelButton" value="cancel"> <input type="button" class="positive" id="popupSaveButton" value="Save"></div>';

        return html;
    }

    function saveAgent() {
        var configuration = {},
            inputs = $('#configurationFields input, #configurationFields textarea');

        configuration.agent = $('#agentType').text();

        inputs.each(function () {
            var input = this,
                fieldName = $(input).attr('id'),
                value;

            switch($(input).attr('type')) {
                case 'checkbox' :
                    value = $(input).prop('checked');
                    break;

                default:
                    value = $(input).val();
                    break;
            }

            configuration[fieldName] = value;
        });

        callApi('saveConfiguration.cgi', configuration)
            .then(function (data) {
                if (data.status == "saved") {
                    hidePopup();
                    $(window).trigger('hashchange');
                } else {
                    alert(data.errorMessage);
                }
            });

    }

    function harvestersPage(parameters) {
        callApi("getHarvestingAgents.cgi")
        .then(function (harvestingAgents) {
            harvestingAgents.forEach(function (harvestingAgent) {
                $('table#harvestingAgents tbody').append(
                    '<tr id="' + harvestingAgent._id.$oid + '"><td class="type"></td><td class="name"></td><td class="status"></td></tr>'
                );
                
                $('#' + harvestingAgent._id.$oid).click(function () {
                    editAgent(harvestingAgent);
                });
                $('#' + harvestingAgent._id.$oid + ' td.type').text(harvestingAgent.agent);
                $('#' + harvestingAgent._id.$oid + ' td.name').text(harvestingAgent.title);
                $('#' + harvestingAgent._id.$oid + ' td.status').text(harvestingAgent.active ? 'Active' : 'Inactive');
            });
        });
    }


    function publishersPage(parameters) {
        callApi("getPublishingAgents.cgi")
        .then(function (publishingAgents) {
            publishingAgents.forEach(function (publishingAgent) {
                $('table#publishingAgents tbody').append(
                    '<tr id="' + publishingAgent._id.$oid + '"><td class="type"></td><td class="name"></td><td class="status"></td></tr>'
                );
                
                $('#' + publishingAgent._id.$oid).click(function () {
                    editAgent(publishingAgent);
                });
                $('#' + publishingAgent._id.$oid + ' td.type').text(publishingAgent.agent);
                $('#' + publishingAgent._id.$oid + ' td.name').text(publishingAgent.title);
                $('#' + publishingAgent._id.$oid + ' td.status').text(publishingAgent.active ? 'Active' : 'Inactive');
            });
        });
    }



    function tweetsPage(parameters) {
        callApi("getTweetLog.cgi")
        .then(function (tweets) {
            tweets.forEach(function (tweet) {
                $('table#tweetLog tbody').append(
                    '<tr id="' + tweet._id.$oid + '"><td class="timestamp"></td><td class="publishingAgent"></td><td class="tweet"></td></tr>'
                );
                
                $('#' + tweet._id.$oid + ' td.timestamp').text(formatTimestamp(tweet.timestamp));
                $('#' + tweet._id.$oid + ' td.publishingAgent').text(tweet.agent);
                $('#' + tweet._id.$oid + ' td.tweet').text(tweet.tweet);

            });
        });
    }

    function postsPage(parameters) {
        callApi("getPostLog.cgi")
        .then(function (posts) {
            posts.forEach(function (post) {
                $('table#postLog tbody').append(
                    '<tr id="' + post._id.$oid + '"><td class="timestamp"></td><td class="publishingAgent"></td><td class="post"></td><td class="postLink"></td></tr>'
                );
                
                $('#' + post._id.$oid + ' td.timestamp').text(formatTimestamp(post.timestamp));
                $('#' + post._id.$oid + ' td.publishingAgent').text(post.agent);
                $('#' + post._id.$oid + ' td.post').text(post.post.message.substr(0,100))
                    .attr('data-message', post.post.message);
                $('#' + post._id.$oid + ' td.postLink').text(post.post.link);
            });
        });
    }

    function formatTimestamp(timestamp) {
        var dateTime = new Date(timestamp),
            day = dateTime.getDate(),
            month = dateTime.getMonth() + 1,
            year = dateTime.getFullYear(),
            hours = dateTime.getHours(),
            minutes = dateTime.getMinutes(),
            seconds = dateTime.getSeconds(),
            formattedTimestamp;
            
        if (day < 10) {
            day = "0" + day;
        }

        if (month < 10) {
            month = "0" + month;
        }

        if (hours < 10) {
            hours = "0" + hours;
        }
        if (minutes < 10) {
            minutes = "0" + minutes;
        }

        if (seconds < 10) {
            seconds = "0" + seconds;
        }

        formattedTimestamp = day + "/" + month + "/" + year + " " + hours + ":" + minutes + ":" +seconds;

        return formattedTimestamp;
    }


    function callApi(api, data) {
        return new Promise(function (resolve, reject) {
            $.ajax({
                url: API_URL + api,
                type: 'GET',
                dataType: 'json',
                data: data || {},
                success: function (data) {
                    resolve(data);
                },
                error: function (textStatus) {
                    reject(textStatus);
                }
            });       
        });
    }


}

/***
 * Startup code
 */
var twitterBotDashboard = new TwitterBotDashboard();
$(document).ready(twitterBotDashboard.run);


