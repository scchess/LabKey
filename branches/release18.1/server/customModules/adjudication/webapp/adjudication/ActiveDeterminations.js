/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('LABKEY.adj.ActiveDeterminationsCombo', {
    extend: 'Ext.form.field.ComboBox',

    name: 'activeCaseCombo',
    fieldLabel: 'Choose Active Case',
    labelWidth: 140,
    displayField: 'CaseDisplay',
    valueField: 'CaseId',
    editable: false,
    width: 350,
    hidden: true,

    determRenderId: null,
    adjid: null,
    ptid: null,
    requiresHiv1: true,
    requiresHiv2: false,
    currentCaseData: {},

    initComponent : function()
    {
        this.adjUtil = Ext4.create('LABKEY.adj.AdjudicationUtil');

        // call getter to init template for the selected grid row determination details
        this.getDetermDetailsView();

        // grid store for the active determinations of the current user
        this.store = Ext4.create('Ext.data.Store', {
            autoLoad: true,
            fields: ['CaseId', 'CaseDisplay'],
            proxy: {
                type: 'ajax',
                url: LABKEY.ActionURL.buildURL("query", "selectRows.api", null, {
                    'schemaName': 'adjudication',
                    'query.queryName': 'Active Adj Determs',
                    'query.UserId~eq': LABKEY.Security.currentUser.id
                }),
                reader: {
                    type: 'json',
                    root: 'rows'
                }
            },
            listeners: {
                scope: this,
                load: this.selectAdjIdRecord
            }
        });

        this.on('select', this.onCaseSelect, this);

        this.callParent();
    },

    selectAdjIdRecord : function(store, records)
    {
        var record = store.getAt(store.find('CaseId', this.adjid));
        if (record)
        {
            this.setValue(this.adjid);
            this.onCaseSelect(this, [record]);
        }

        // show the case selection combo if we have multiple active case or one isn't selected
        if (records.length > 1 || !record)
            this.show();
    },

    onCaseSelect : function(combo, records)
    {
        if (!Ext4.isArray(records) || records.length != 1)
            return;

        var record = records[0];

        // hold on to the key values from the selected row
        this.adjid = record.get("CaseId");
        this.ptid = record.get("ParticipantId");

        // update page nav trail and combo display
        var titlePrefix = "Adjudication Determinations";
        if (LABKEY.getModuleContext("adjudication").ProtocolName != null)
            titlePrefix = LABKEY.getModuleContext("adjudication").ProtocolName + " - " + titlePrefix;
        LABKEY.NavTrail.setTrail(Ext4.util.Format.htmlEncode(titlePrefix + " - Case ID " + this.adjid));
        this.setFieldLabel('Change Active Case');

        this.currentCaseData = {
            caseSummary: {
                CaseId: this.adjid,
                ParticipantId: this.ptid,
                CreatedDate: record.get("Created") == null ? "" : this.adjUtil.formatDate(record.get("Created")),
                Comments: record.get("Comment") == null ? "" : Ext4.util.Format.htmlEncode(record.get("Comment")).replace(/[\r]?\n/g, "<br/>")
            }
        };

        // update possible infection date store
        this.queryPossibleInfectionDates();

        // update the determ view, and start querying the data
        this.getDetermDetailsView().update(this.currentCaseData);
        this.queryOtherCasesForPtid();
    },

    queryPossibleInfectionDates : function()
    {
        // get the list of possible infection dates for the given adjudication
        LABKEY.Query.selectRows({
            schemaName: "adjudication",
            queryName: "Draw Dates",
            filterArray: [LABKEY.Filter.create('CaseId', this.adjid)],
            success: this.adjUtil.storeDrawDates,
            failure: this.adjUtil.failureHandler,
            scope: this.adjUtil
        });
    },

    queryOtherCasesForPtid : function()
    {
        // query the database to see if this ptids has previously been adjudicated
        LABKEY.Query.selectRows({
            schemaName: 'adjudication',
            queryName: 'AdjudicationCase',
            filterArray: [
                LABKEY.Filter.create('ParticipantId', this.ptid),
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

        // get the records from the Adjudication Determinations table for the review table
        LABKEY.Query.selectRows({
            schemaName: "adjudication",
            queryName: "Determinations With UserInfo",
            filterArray: [
                LABKEY.Filter.create('CaseId', this.adjid),
                LABKEY.Filter.create('UserId', LABKEY.Security.currentUser.id)
            ],
            success: this.showSelectedDeterminationDetails,
            failure: this.adjUtil.failureHandler,
            scope: this
        });
    },

    showSelectedDeterminationDetails : function(data)
    {
        var origRow = data.rows.length == 1 ? data.rows[0] : {},
            formatRow = Ext4.clone(origRow);

        // TODO: should we give an error if there is more than one determination for the given user/case?
        if (data.rows.length == 1)
        {
            formatRow.Hiv1Comment = formatRow.Hiv1Comment == null ? '' : Ext4.util.Format.htmlEncode(formatRow.Hiv1Comment).replace(/[\r]?\n/g, "<br/>");
            formatRow.Hiv1InfectedDate = formatRow.Hiv1InfectedDate == null ? '' : this.adjUtil.formatDate(formatRow.Hiv1InfectedDate);
            formatRow.Hiv2Comment = formatRow.Hiv2Comment == null ? '' : Ext4.util.Format.htmlEncode(formatRow.Hiv2Comment).replace(/[\r]?\n/g, "<br/>");
            formatRow.Hiv2InfectedDate = formatRow.Hiv2InfectedDate == null ? '' : this.adjUtil.formatDate(formatRow.Hiv2InfectedDate);
        }
        this.currentCaseData.determination = formatRow;

        this.getDetermDetailsView().update(this.currentCaseData);
        this.adjUtil.showAssayResults.call(this.adjUtil, this.currentCaseData.assayResultsResponse, this.currentCaseData.caseSummary);

        // show the make determination button
        Ext4.create('Ext.button.Button', {
            renderTo: 'determButton',
            text: this.currentCaseData.determination && this.currentCaseData.determination.Status == 'completed' ? 'Change Determination' : 'Make Determination',
            scope: this,
            handler: function()
            {
                // this is the form used to make the adj. determ. that pops up when the determ. button is clicked
                Ext4.create('LABKEY.adj.MakeDeterminationWindow', {
                    adjid: this.adjid,
                    ptid: this.ptid,
                    initData: origRow,
                    requiresHiv1: this.requiresHiv1,
                    requiresHiv2: this.requiresHiv2,
                    adjUtil: this.adjUtil
                });
            }
        });

        this.removeCaseNotifications();

        LABKEY.Utils.signalWebDriverTest("determinationTablesLoaded");
    },

    getDetermDetailsView : function()
    {
        if (!this.determDetailsView)
        {
            this.determDetailsView = Ext4.create('LABKEY.adj.ActiveDeterminationDetails', {
                renderTo: this.determRenderId,
                requiresHiv1: this.requiresHiv1,
                requiresHiv2: this.requiresHiv2,
                adjUtil: this.adjUtil
            })
        }

        return this.determDetailsView;
    },

    removeCaseNotifications : function()
    {
        // call api action to remove any UI notifications for this user for this case
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'removeCaseNotifications'),
            method: 'POST',
            jsonData: {
                adjid: this.adjid
            },
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
    }
});

Ext4.define('LABKEY.adj.ActiveDeterminationDetails', {
    extend: 'Ext.view.View',

    initComponent : function()
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
                "<table class='result-case-section'>",
                " <tr>",
                "  <td class='result-case-summary'>Participant ID:</td>",
                "  <td>{caseSummary.ParticipantId}</td>",
                " </tr>",
                " <tr>",
                "  <td class='result-case-summary'>Creation date:</td>",
                "  <td>{caseSummary.CreatedDate}</td>",
                " </tr>",
                " <tr>",
                "  <td class='result-case-summary'>Comments:</td>",
                "  <td width='665'>{caseSummary.Comments}</td>",
                " </tr>",
                "</table>",
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
            "<tpl if='determination != undefined'>",
            "<table>",
            " <tr>",
            "  <td colspan='2'><div class='result-field-header'>Adjudication Determination</div></td>",
            " </tr>",
            " <tr>",
            "  <td class='result-case-determ result-case-padding'>Determination:</td>",
            "  <td class='result-case-padding'><b>{determination.Status}</b> <span id='determButton'></span></td>",
            " </tr>",
            "</table>",
            "<div id='compDeterm'>",
            " <table class='result-case-section'>"
        ]);
        if (this.requiresHiv1)
        {
            tplArr = tplArr.concat([
                "  <tr>",
                "   <td class='result-case-determ'>HIV-1 confirmed infection:</td>",
                "   <td>{determination.Hiv1Infected}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ'>HIV-1 date of diagnosis:</td>",
                "   <td>{determination.Hiv1InfectedDate}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ result-case-padding'>HIV-1 comment:</td>",
                "   <td class='result-case-padding'>{determination.Hiv1Comment}</td>",
                "  </tr>"
            ]);
        }
        if (this.requiresHiv2)
        {
            tplArr = tplArr.concat([
                "  <tr>",
                "   <td class='result-case-determ'>HIV-2 confirmed infection:</td>",
                "   <td>{determination.Hiv2Infected}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ'>HIV-2 date of diagnosis:</td>",
                "   <td>{determination.Hiv2InfectedDate}</td>",
                "  </tr>",
                "  <tr>",
                "   <td class='result-case-determ result-case-padding'>HIV-2 comment:</td>",
                "   <td class='result-case-padding'>{determination.Hiv2Comment}</td>",
                "  </tr>"
            ]);
        }
        tplArr = tplArr.concat([
            " </table>",
            "</div>",
            "</tpl>"
        ]);

        this.tpl = new Ext4.XTemplate(tplArr);

        this.callParent();
    }
});