/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

// Build Admin or Adjudication Dashboard

Ext4.define('LABKEY.adj.Dashboard', {

    extend: 'Ext.Component',

    /**
     * user is an Adjudication Admin for the folder (not necessarily folder admin or site admin) viewing the Admin Dashboard
     */
    isAdjudicationAdmin: false,

    hasPermission: false,

    adjudicatorTeamNumber: null,

    numAdjudicatorTeams: 2,

    initComponent: function()
    {
        this.renderTpl = new Ext4.XTemplate(
            '<div style="margin-left: 20px">',
                '<div class="viewOptions" style="margin-left: 675px;"></div>',
                '<div class="gridOne"></div>',
                '<div class="gridTwo"></div>',
            '</div>'
        );

        this.renderSelectors = {
            viewOptions: 'div.viewOptions',
            gridOne: 'div.gridOne',
            gridTwo: 'div.gridTwo'
        };

        this.callParent();

        this.on('afterrender', function(dashboard)
        {
            if (this.hasPermission)
            {
                dashboard.gridOne.update('Loading....');
                this.loadAdjudicationData();
            }
            else
            {
                dashboard.gridOne.update('');
                dashboard.gridTwo.update('<div class="labkey-error">You do not have permission to view this dashboard.</div>');
            }
        }, this, {single: true});
    },

    loadAdjudicationData : function()
    {
        // get the list of possible states
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'Status',
            sort: 'SequenceOrder',
            success: function (data)
            {
                var stateData = data;

                // get all of the data for the dashboard from a predefined query
                LABKEY.Query.selectRows({
                    schemaName: 'adjudication',
                    queryName: 'Determinations With UserInfo',
                    success: function (data)
                    {
                        // Determination records are duplicated by number of adjudicators in each team
                        var determinationData = data;

                        // If adjudicator, show only his/her determinations
                        var filter = [];
                        if (!this.isAdjudicationAdmin)
                        {
                            filter.push(LABKEY.Filter.create('UserId', LABKEY.Security.currentUser.id));
                        }

                        // get all of the data for the dashboard from a predefined query
                        LABKEY.Query.selectRows({
                            schemaName: 'adjudication',
                            queryName: 'Adjudication Dashboard',
                            sort: '-Completed,-Created',
                            filterArray: filter,
                            success: function (data)
                            {
                                this.renderDashboard(data, stateData, determinationData);
                            },
                            failure: this.failureHandler,
                            scope: this
                        });
                    },
                    failure: this.failureHandler,
                    scope: this
                });
            },
            failure: this.failureHandler,
            scope: this
        });
    },

    renderDashboard : function(caseData, stateData, determinationData)
    {
        // number of milliseconds in one day
        var one_day = 1000 * 60 * 60 * 24;

        // if there is no data, then display a message and return
        if (caseData.rowCount == 0)
        {
            this.gridOne.update('No Data Currently Available.');
            LABKEY.Utils.signalWebDriverTest('adjudicationDashboardComplete');
            return;
        }

        var caseDeterminationMap = this.makeCaseDeterminationMap(determinationData);

        this.renderViewOptions();

        // loop through the states to build the html dashboard table for that state
        for (var j = 0; j < stateData.rowCount; j++)
        {
            // store the current state and the grid number (based on order of states)
            var state = stateData.rows[j].Status;
            var gridNum = stateData.rows[j].SequenceOrder;

            // to be used in colspan elements
            var numcols = 0;

            // start of the html string for this state
            var html = '';
            
            if (state == 'Active Adjudication')
            {
                html += "<div style='font-weight: bold; font-size: 16px; color: #333'>Active</div>";
                html += "Sort: Case Creation Date, Descending";
                numcols = 7;
            }
            else if (state == 'Complete')
            {
                html += "<div style='font-weight: bold; font-size: 16px; color: #333'>Completed</div>";
                html += "Sort: Case Completion Date, Descending";
                numcols = 6;
            }

            html += "<table class='labkey-data-region-legacy labkey-show-borders' width='850px'>";

            // column headers will differ depending on the state
            if (state == 'Complete')
            {
                html += "<tr><td class='labkey-column-header' width='60px'>&nbsp;</td>"
                        + "<td class='labkey-column-header'>Case ID</td>"
                        + "<td class='labkey-column-header'>Participant ID</td>"
                        + "<td class='labkey-column-header'>Case Creation Date</td>"
                        + "<td class='labkey-column-header'>Case Completion Date</td>"
                        + "<td class='labkey-column-header'>Adj Recorded<br/>at Lab</td></tr>";
            }
            else if (state == 'Active Adjudication')
            {
                html += "<tr><td class='labkey-column-header' width='60px'>&nbsp;</td>"
                        + "<td class='labkey-column-header'>Case ID</td>"
                        + "<td class='labkey-column-header'>Participant ID</td>"
                        + "<td class='labkey-column-header'>Case Creation Date</td>"
                        + "<td class='labkey-column-header'># Days Since<br/>Case Creation</td>"
                        + "<td class='labkey-column-header'>Status</td>";
            }

            // count of the number of cases in this state
            var count = 0;

            // loop through all cases filtering for those in the current state
            for (var i = 0; i < caseData.rowCount; i++)
            {
                var caseRow = caseData.rows[i];
                if (caseRow.Status == state)
                {
                    count++;
                    var caseId = caseRow.CaseId;

                    // alternate row background shading (white and gray)
                    if (count % 2 == 1)
                        html += "<tr class='labkey-alternate-row'>";
                    else
                        html += "<tr class='labkey-row'>";

                    if (this.isAdjudicationAdmin)
                    {
                        var href = LABKEY.ActionURL.buildURL('adjudication', 'adjudicationReview', null, {
                            adjid: caseId,
                            isAdminReview: true
                        });
                        html += "<td>&nbsp;<a class='labkey-text-link' href='" + href + "'>details</a></td>";
                    }
                    else
                    {
                        // Get determination for this user (all fields except userId are same for users in same team)
                        var determination;
                        for (var detNum = 0; detNum < caseDeterminationMap[caseId].length; detNum++)
                        {
                            determination = caseDeterminationMap[caseId][detNum];
                            if (determination && determination.UserId == LABKEY.Security.currentUser.id)
                                break;
                        }

                        // set up the appropriate link to the details view of this case
                        if (state == 'Complete' || !determination || 'completed' == determination.Status)
                        {
                            var href2 = LABKEY.ActionURL.buildURL('adjudication', 'adjudicationReview', null, {
                                adjid: caseId,
                                isAdminReview: false
                            });
                            html += "<td>&nbsp;<a class='labkey-text-link' href='" + href2 + "'>details</a></td>";
                        }
                        else
                        {
                            var href1 = LABKEY.ActionURL.buildURL('adjudication', 'adjudicationDetermination', null, {
                                adjid: caseId
                            });
                            html += "<td>&nbsp;<a class='labkey-text-link' href='" + href1 + "'>update</a></td>";
                        }
                    }

                    // if there is a case comment, we want to display it as a hover-over pop-up window
                    var commPopup = "";
                    if (caseRow.Comment != null)
                    {
                        var comment = (caseRow.Comment).replace(/[\r]?\n/g, "<br>");
                        comment = comment.replace(/\'/g, "&rsquo;");
                        // TODO comment needs to be html encoded

                        commPopup = "<a href='#' onClick='return false;' onMouseOut='return hideHelpDivDelay();'"
                                + " onMouseOver='return showHelpDiv(this, &#039;Comments&#039;, &#039;"
                                + comment + "&#039;);'>"
                                + "<span class='labkey-help-pop-up'><sup>?</sup></span></a>";
                    }

                    // add adj. ID and ptid to the html table
                    html += "<td>" + caseId + commPopup + "</td>";
                    html += "<td>" + caseRow.ParticipantId + "</td>";

                    // add date case was created to the table (in the proper date format)
                    var createDate = new Date(caseRow.Created);
                    html += "<td>" + Ext4.util.Format.date(createDate, 'd-M-y') + "</td>";

                    // for active cases, calculate and display the number of days since case creation
                    if (state == 'Active Adjudication')
                    {
                        // calculate and display the number of days since case creation
                        var dayDiff = ((new Date()) - createDate) / one_day;
                        // round down by converting to a string and chopping off at the decimal point
                        dayDiff += '';
                        dayDiff = dayDiff.substring(0, dayDiff.indexOf("."));

                        // highlight and bold the dayDiff if > 4
                        var dayStyle = dayDiff > 4 ? "style='font-weight:bold;color:red'" : "";
                        html += "<td " + dayStyle + ">" + dayDiff + "</td>";

                        // Status
                        var statusText, statusStyle = "";
                        if (this.isAdjudicationAdmin)
                        {
                            // Number of adjudicator teams defined in ManageSettings
                            var teams = caseRow['AdjudicatorTeamNumbers'][0].split(',');
                            if (teams.length == this.numAdjudicatorTeams)
                                statusText = this.getActiveCaseStatusText(caseDeterminationMap, caseId);
                            else
                                statusText = this.numAdjudicatorTeams + " Adjudicators not assigned"
                        }
                        else
                        {
                            statusText = this.getActiveCaseStatusText(caseDeterminationMap, caseId, LABKEY.Security.currentUser.id);
                        }

                        // highlight status values that are marked as needing follow-up actions besides determinations
                        if (statusText.toLowerCase() == 'further testing required' || statusText.toLowerCase() == 'resolution required')
                            statusStyle = "style='color:red;'";

                        html += "<td " + statusStyle + ">" + statusText + "</td>";
                    }

                    // for complete cases, add the completed date
                    if (state == 'Complete')
                    {
                        var completedDate = new Date(caseRow.Completed);
                        html += "<td>" + Ext4.util.Format.date(completedDate, 'd-M-y') + "</td>";

                        if (caseRow.LabVerified == null)
                        {
                            html += "<td>&nbsp;</td>";
                        }
                        else
                        {
                            var verifiedDate = new Date(caseRow.LabVerified);
                            html += "<td>" + Ext4.util.Format.date(verifiedDate, 'd-M-y') + "</td>";
                        }
                    }

                    html += "</tr>";
                }// end of if(caseData.rows[i].Status == state)
            }// end of for(var i=0; i<caseData.rowCount; i++)

            // add the count of the number of cases in this state
            html += "<tr class='labkey-row'><td colspan='" + numcols
                    + "' align='right' style='font-style: italic'>Count: " + count + "</td></tr>";

            html += "</table><br>";

            if (gridNum === 1)
                this.gridOne.update(html);
            else
                this.gridTwo.update(html);
        }// end of loop through states

        LABKEY.Utils.signalWebDriverTest('adjudicationDashboardComplete');
    },

    renderViewOptions : function()
    {
        var options = Ext4.create('Ext.data.Store', {
            fields: ['value', 'name'],
            data: [
                {'value': 0, 'name': 'Show All'},
                {'value': 1, 'name': 'Active'},
                {'value': 2, 'name': 'Completed'}
            ]
        });

        Ext4.create('Ext.form.ComboBox', {
            fieldLabel: 'View',
            width: 175,
            labelWidth: 50,
            store: options,
            queryMode: 'local',
            displayField: 'name',
            valueField: 'value',
            value: 0,
            renderTo: this.viewOptions,
            listeners: {
                scope: this,
                'select': this.toggle
            }
        })
    },

    makeCaseDeterminationMap : function(determinationData)
    {
        // Map caseId --> [rowData]
        var mapCase = {};
        for (var i = 0; i < determinationData.rowCount; i++)
        {
            var caseId = determinationData.rows[i].CaseId;
            if (!mapCase[caseId])
                mapCase[caseId] = [];
            mapCase[caseId].push(determinationData.rows[i]);
        }
        return mapCase;
    },

    getActiveCaseStatusText : function(caseDeterminationMap, caseId, userId)
    {
        // Split determination records by teamNumber and keep track of one determination record per teamNumber
        var teamUserDeterminationMap = {}, teamDeterminations = [];
        for (var detNum = 0; detNum < caseDeterminationMap[caseId].length; detNum++)
        {
            var determ = caseDeterminationMap[caseId][detNum],
                teamNumber = determ['AdjudicatorTeamNumber'];

            if (!Ext4.isArray(teamUserDeterminationMap[teamNumber]))
            {
                teamUserDeterminationMap[teamNumber] = [];
                teamDeterminations.push(determ);
            }

            teamUserDeterminationMap[teamNumber].push(determ);
        }

        if (teamDeterminations.length > 0)
        {
            var uniqueStatuses = Ext4.Array.unique(Ext4.Array.pluck(teamDeterminations, 'Status')),
                uniqueHiv1Infected = Ext4.Array.unique(Ext4.Array.pluck(teamDeterminations, 'Hiv1Infected')),
                hiv1InfectedMatch = uniqueHiv1Infected.length == 1,
                uniqueHiv2Infected = Ext4.Array.unique(Ext4.Array.pluck(teamDeterminations, 'Hiv2Infected')),
                hiv2InfectedMatch = uniqueHiv2Infected.length == 1,
                allPending = uniqueStatuses.length == 1 && uniqueStatuses[0] == 'pending',
                allHaveDeterms = !Ext4.Array.contains(uniqueHiv1Infected, null) || !Ext4.Array.contains(uniqueHiv2Infected, null);

            if (allPending && hiv1InfectedMatch && hiv2InfectedMatch && uniqueHiv1Infected[0] == null && uniqueHiv2Infected[0] == null)
            {
                return 'Not started';
            }
            else if (allPending && ((hiv1InfectedMatch && uniqueHiv1Infected[0] == 'Further Testing Required')
                    || (hiv2InfectedMatch && uniqueHiv2Infected[0] == 'Further Testing Required')))
            {
                return 'Further testing required';
            }
            // all adjudicators have determinations and hiv1 status doesn't match, hiv2 status doesn't match,
            // or match is 'Yes' with different diagnosis dates
            else if (allHaveDeterms && (!hiv1InfectedMatch || !hiv2InfectedMatch
                    || ((uniqueHiv1Infected.length == 1 && uniqueHiv1Infected[0] == 'Yes')
                    || (uniqueHiv2Infected.length == 1 && uniqueHiv2Infected[0] == 'Yes'))))
            {
                // all adj teams have made determinations and they don't all match or they all match as 'Yes' but there is a date mismatch
                return 'Resolution required';
            }
            else if (userId)
            {
                var usersDetermination = this.getUsersDetermination(userId, caseDeterminationMap[caseId]),
                    userHasDetermintion = usersDetermination.Hiv1Infected != null || usersDetermination.Hiv2Infected != null;

                if (userHasDetermintion)
                {
                    if (usersDetermination.LastUpdatedBy == LABKEY.user.email)
                        return 'You made determination';
                    else
                        return 'Other adjudicator in same team made determination';
                }
                else
                {
                    return 'Adjudicator in other team' + (this.numAdjudicatorTeams > 2 ? '(s)' : '') + ' made determination';
                }
            }
            else if (!hiv1InfectedMatch && Ext4.Array.contains(uniqueHiv1Infected, null))
            {
                var nonNullDeterms = Ext4.Array.filter(Ext4.Array.pluck(teamDeterminations, 'Hiv1Infected'), function(item) { return item != null });
                return nonNullDeterms.length + ' of ' + this.numAdjudicatorTeams + ' adjudicators made determinations';
            }
            else if (!hiv2InfectedMatch && Ext4.Array.contains(uniqueHiv2Infected, null))
            {
                var nonNullDeterms = Ext4.Array.filter(Ext4.Array.pluck(teamDeterminations, 'Hiv2Infected'), function(item) { return item != null });
                return nonNullDeterms.length + ' of ' + this.numAdjudicatorTeams + ' adjudicators made determinations';
            }
        }

        return 'Unknown';
    },

    getUsersDetermination : function(userId, determinations)
    {
        for (var detNum = 0; detNum < determinations.length; detNum++)
        {
            if (determinations[detNum].UserId == userId)
                return determinations[detNum];
        }
        return {};
    },

    // toggle between showing a given state's dashboard table and hiding it
    toggle : function(combo)
    {
        var gridNum = combo.getValue();
        if (gridNum === 1)
        {
            this.gridOne.dom.style.display = 'block';
            this.gridTwo.dom.style.display = 'none';
        }
        else if (gridNum === 2)
        {
            this.gridOne.dom.style.display = 'none';
            this.gridTwo.dom.style.display = 'block';
        }
        else if (gridNum === 0)
        {
            this.gridOne.dom.style.display = 'block';
            this.gridTwo.dom.style.display = 'block';
        }
        else
        {
            this.gridOne.dom.style.display = 'none';
            this.gridTwo.dom.style.display = 'none';
        }
    },

    // generic error callback function for many api calls
    failureHandler : function(errorInfo, response)
    {
        if (errorInfo && errorInfo.exception)
            LABKEY.Utils.alert("ERROR", errorInfo.exception);
        else
            LABKEY.Utils.alert("ERROR", response.statusText);
    }

});