/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('LABKEY.adj.AdjudicationReview', {
    extend: 'Ext.view.View',

    adjid: null,
    ptid: null,
    requiresHiv1: true,
    requiresHiv2: false,
    isAdminReview: false,
    canEditComments: false,
    canVerifyReceipt: false,
    currentCaseData: {},

    initComponent: function ()
    {
        this.adjUtil = Ext4.create('LABKEY.adj.AdjudicationUtil');

        this.tpl = new Ext4.XTemplate(this.getTplArr());

        this.callParent();

        if (this.currentCaseData.caseSummary)
        {
            var val = this.currentCaseData.caseSummary.Created;
            this.currentCaseData.caseSummary.CreatedDate = Ext4.isString(val) ? this.adjUtil.formatDate(val) : null;

            val = this.currentCaseData.caseSummary.Completed;
            this.currentCaseData.caseSummary.CompletedDate = Ext4.isString(val) ? this.adjUtil.formatDate(val) : null;

            val = this.currentCaseData.caseSummary.LabVerified;
            this.currentCaseData.caseSummary.LabVerifiedDate = Ext4.isString(val) ? this.adjUtil.formatDate(val) : null;

            val = this.currentCaseData.caseSummary.Comment;
            this.currentCaseData.caseSummary.Comments = val == null ? "" : Ext4.util.Format.htmlEncode(val).replace(/[\r]?\n/g, "<br/>");
        }

        this.queryOtherCasesForPtid();
    },

    queryOtherCasesForPtid : function()
    {
        // query the database to see if this ptid has previously been adjudicated
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'AdjudicationCase',
            filterArray: [LABKEY.Filter.create('ParticipantId', this.ptid),
                LABKEY.Filter.create('CaseId', this.adjid, LABKEY.Filter.Types.NOT_EQUAL)],
            success: this.queryAssayResults,
            failure: this.adjUtil.failureHandler,
            scope: this
        });
    },

    queryAssayResults : function(data)
    {
        if (data.rows.length > 0)
        {
            this.currentCaseData.otherCaseIds = Ext4.Array.pluck(data.rows, 'CaseId').join(', ');
        }

        // get the assay results related to this adj. case
        LABKEY.Query.selectRows({
            schemaName: "adjudication",
            queryName: "Adjudication Assay Results",
            filterArray: [LABKEY.Filter.create('CaseId', this.adjid)],
            success: this.queryAdjudicatorDeterminations,
            failure: this.adjUtil.failureHandler,
            scope: this
        });
    },

    queryAdjudicatorDeterminations : function(data)
    {
        this.currentCaseData.assayResultsResponse = data;

        // If adjudicator, show only his/her determinations unless Complete
        var filter = [LABKEY.Filter.create('CaseId', this.adjid)];
        if (!this.isAdminReview && this.currentCaseData.caseSummary.Status != 'Complete')
            filter.push(LABKEY.Filter.create('UserId', LABKEY.Security.currentUser.id));

        // get the records from the Adjudication Determinations table for the review table
        LABKEY.Query.selectRows({
            schemaName: "adjudication",
            queryName: "Determinations With UserInfo",
            filterArray: filter,
            success: this.showAdjudicationCaseDetails,
            failure: this.adjUtil.failureHandler,
            scope: this
        });
    },

    showAdjudicationCaseDetails : function(data)
    {
        var determinations = [],
            seenTeam = {},
            determIndex = 0;

        for (var i = 0; i < data.rows.length; i++)
        {
            var row =  data.rows[i],
                teamNumber = row.AdjudicatorTeamNumber,
                determCompleted = row.Completed != null;

            if (!Ext4.isDefined(seenTeam[teamNumber]))
            {
                determinations.push({
                    TeamNumber: teamNumber,
                    Status: row.Status,
                    Completed: row.Completed == null ? "" : this.adjUtil.formatDate(row.Completed),
                    Adjudicators: [],

                    Hiv1Infected: row.Hiv1Infected,
                    Hiv1InfectedDate: row.Hiv1InfectedDate == null ? "" : this.adjUtil.formatDate(row.Hiv1InfectedDate),
                    Hiv1Comment: row.Hiv1Comment == null ? "" : Ext4.util.Format.htmlEncode(row.Hiv1Comment).replace(/[\r]?\n/g, '<br/>'),
                    Hiv2Infected: row.Hiv2Infected,
                    Hiv2InfectedDate: row.Hiv2InfectedDate == null ? "" : this.adjUtil.formatDate(row.Hiv2InfectedDate),
                    Hiv2Comment: row.Hiv2Comment == null ? "" : Ext4.util.Format.htmlEncode(row.Hiv2Comment).replace(/[\r]?\n/g, '<br/>')
                });

                seenTeam[teamNumber] = determIndex;
                determIndex++;
            }

            determinations[seenTeam[teamNumber]].Adjudicators.push(row['Email'] ? row['Email'] : row['DisplayName']);

            // if the determination is completed, show the user that last updated it
            // otherwise list the adjudicators for the given teamNumber
            determinations[seenTeam[teamNumber]].Adjudicator = determCompleted ? row['LastUpdatedBy'] : determinations[seenTeam[teamNumber]].Adjudicators.join(', ');
        }
        this.currentCaseData.determinations = determinations;

        this.update(this.currentCaseData);
        this.adjUtil.showAssayResults.call(this.adjUtil, this.currentCaseData.assayResultsResponse, this.currentCaseData.caseSummary);

        this.attachActionButtons();

        this.removeCaseNotifications();

        LABKEY.Utils.signalWebDriverTest("determinationTablesLoaded");
    },

    attachActionButtons : function()
    {
        if (this.isAdminReview && this.canEditComments && Ext4.get('editCaseComments') != null)
        {
            Ext4.create('Ext.button.Button', {
                renderTo: 'editCaseComments',
                text: 'Edit Comments',
                handler: this.editCaseComments,
                scope: this
            });
        }

        if (this.isAdminReview && this.canVerifyReceipt && this.currentCaseData.caseSummary.Status == 'Complete' && Ext4.get('verifyLabReceipt'))
        {
            Ext4.create('Ext.button.Button', {
                renderTo: 'verifyLabReceipt',
                text: 'Verify Receipt of Determination',
                handler: this.verifyLabReceipt,
                scope: this
            });
        }

        if (!this.isAdminReview && this.currentCaseData.caseSummary.Status != 'Complete' && Ext4.get('adjChangeDetermination'))
        {
            Ext4.get('adjChangeDetermination').update("<a class='labkey-text-link' href='"
                    + LABKEY.ActionURL.buildURL('adjudication', 'adjudicationDetermination', null, {adjid: this.adjid})
                    + "'>Change Determination</a>");
        }
    },

    editCaseComments : function()
    {
        // allow the admin coordinator the edit comments for an adjudication case via a pop-up window
        Ext4.create('Ext.window.Window', {
            autoShow: true,
            width: 300,
            height: 300,
            layout: 'fit',
            border: false,
            bodyPadding: 5,
            items: [{
                xtype: 'textarea',
                value: this.currentCaseData.caseSummary.Comment
            }],
            buttons: [{
                text: 'Save Changes',
                scope: this,
                handler: function(button) {
                    // call update api to store any changes to the comment field
                    LABKEY.Query.updateRows({
                        schemaName: "adjudication",
                        queryName: "AdjudicationCase",
                        rows: [{
                            CaseId: this.adjid,
                            Comment: button.up('window').down('textarea').getValue()
                        }],
                        success: function() { window.location.reload(); },
                        failure: this.adjUtil.failureHandler,
                        scope: this
                    });
                }
            },  {
                text: 'Cancel',
                handler: function() {
                    this.up('window').close();
                }
            }],
            modal: true,
            title: "Edit Comments"
        })
    },

    verifyLabReceipt : function()
    {
        // call api to set the verification date and remove related UI notifications
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'verifyLabReceipt'),
            method: 'POST',
            jsonData: { adjid: this.adjid },
            success: function (response)
            {
                window.location.reload();
            },
            failure: this.failureHandler,
            scope: this
        });
    },

    removeCaseNotifications : function()
    {
        // call api action to remove any UI notifications for this user for this case
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'removeCaseNotifications'),
            method: 'POST',
            jsonData: { adjid: this.adjid },
            success: function (response) {},
            failure: this.failureHandler,
            scope: this
        });
    },

    failureHandler : function(response)
    {
        var msg = response.status == 403 ? response.statusText : Ext4.JSON.decode(response.responseText).exception;
        Ext4.Msg.show({
            title:'Error',
            msg: msg,
            buttons: Ext4.Msg.OK,
            icon: Ext4.Msg.ERROR
        });
    },

    getTplArr : function()
    {
        var tplArr = [];

        // Other Related Cases section
        tplArr = tplArr.concat([
            "<tpl if='otherCaseIds != undefined'>",
                "<div class='result-other-cases result-case-section'>This participant is being or has been adjudicated in other cases: {otherCaseIds}</div>",
            "</tpl>"
        ]);

        // Case Summary section
        tplArr = tplArr.concat([
            "<tpl if='caseSummary != undefined'>",
                "<div id='caseSummary'><table class='result-case-section'>",
                "<div style='display:none' id='adj' value='{caseSummary.CaseId}'></div>", // for selenium testing
                " <tr>",
                "  <td class='result-case-summary'>Participant ID:</td>",
                "  <td id='ptid'>{caseSummary.ParticipantId}</td>",
                " </tr>",
                " <tr>",
                "  <td class='result-case-summary'>Status:</td>",
                "  <td id='state'>{caseSummary.Status}</td>",
                " </tr>",
                " <tr>",
                "  <td class='result-case-summary'>Creation date:</td>",
                "  <td id='casecreate'>{caseSummary.CreatedDate}</td>",
                " </tr>",
                " <tr>",
                "  <td class='result-case-summary'>Completion date:</td>",
                "  <td id='casecomplete'>{caseSummary.CompletedDate}</td>",
                " </tr>",
                " <tr>",
                "  <td class='result-case-summary'>Comments:</td>",
                "  <td width='665'><div id='comments'>{caseSummary.Comments}</div><div id='editCaseComments'></div></td>",
                " </tr>",
                "</table></div>",
            "</tpl>"
        ]);

        // Visit Assay Results section, note: rendered with AdjudicationUtil.showAssayResults
        tplArr = tplArr.concat([
            "<tpl if='assayResultsResponse != undefined'>",
                "<div id='assayRes' class='result-case-section'></div>",
            "</tpl>"
        ]);

        // Adjudication Determination section
        tplArr = tplArr.concat([
            "<tpl if='determinations != undefined'>",
                "<tpl for='determinations'>",
                    "<table class='result-case-section' id='determinationTable{TeamNumber}'>",
                    " <tr>",
                    "  <td colspan='2'><div class='result-field-header'>Adjudication Determination {TeamNumber}</div></td>",
                    " </tr>",
                    " <tr>",
                    "  <td class='result-case-determ'>Determination:</td>",
                    "  <td id='deter{TeamNumber}'>{Status}</td>",
                    " </tr>",
                    " </tr>",
                    " <tr>",
                    "  <td class='result-case-determ'>Completion date:</td>",
                    "  <td id='compdt{TeamNumber}'>{Completed}</td>",
                    " </tr>",
                    " </tr>",
                    " <tr>",
                    "  <td class='result-case-determ'>Adjudicator:</td>",
                    "  <td id='adjor{TeamNumber}' class='result-case-padding'>{Adjudicator}</td>",
                    " </tr>"
        ]);
        if (this.requiresHiv1)
        {
            tplArr = tplArr.concat([
                "  <tr>",
                "   <td class='result-case-determ'>HIV-1 confirmed infection:</td>",
                "   <td id='hiv1Inf{TeamNumber}'>{Hiv1Infected}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ'>HIV-1 date of diagnosis:</td>",
                "   <td id='hiv1Infdt{TeamNumber}'>{Hiv1InfectedDate}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ result-case-padding'>HIV-1 comment:</td>",
                "   <td class='result-case-padding' id='hiv1comm{TeamNumber}'>{Hiv1Comment}</td>",
                "  </tr>"
            ]);
        }
        if (this.requiresHiv2)
        {
            tplArr = tplArr.concat([
                "  <tr>",
                "   <td class='result-case-determ'>HIV-2 confirmed infection:</td>",
                "   <td id='hiv2Inf{TeamNumber}'>{Hiv2Infected}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ'>HIV-2 date of diagnosis:</td>",
                "   <td id='hiv2Infdt{TeamNumber}'>{Hiv2InfectedDate}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ result-case-padding'>HIV-2 comment:</td>",
                "   <td class='result-case-padding' id='hiv2comm{TeamNumber}'>{Hiv2Comment}</td>",
                "  </tr>"
            ]);
        }
        if (!this.isAdminReview && this.currentCaseData.caseSummary.Status != 'Complete')
        {
            tplArr = tplArr.concat([
                "  <tr>",
                "   <td colspan='2'><div id='adjChangeDetermination'></div></td>",
                "  </tr>"
            ]);
        }
        tplArr = tplArr.concat([
                    " </table>",
                "</tpl>",
            "</tpl>"
        ]);

        // Lab Verification section
        tplArr = tplArr.concat([
            "<tpl if='caseSummary != undefined && caseSummary.Status == \"Complete\"'>",
                "<div class='result-case-section'",
                " <table>",
                "  <tr>",
                "   <td colspan='2'><div class='result-field-header'>Lab Verification</div></td>",
                "  </tr>",
                "  <tpl if='caseSummary.LabVerifiedDate != null'>",
                "   <tr>",
                "    <td class='result-case-determ'>Date Data Received:</td>",
                "    <td><span id='labverifydate'>{caseSummary.LabVerifiedDate}</span></td>",
                "   </tr>",
                "  <tpl else>",
                "   <tr><td colspan='2'><div id='verifyLabReceipt'></div></td></tr>",
                "  </tpl>",
                " </table>",
                "</div>",
            "</tpl>"
        ]);

        return tplArr;
    }
});