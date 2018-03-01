/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('LABKEY.adj.MakeDeterminationWindow', {
    extend: 'Ext.window.Window',

    layout: 'fit',
    title: "Adjudication Determination Form",
    modal: true,
    autoShow: true,

    // initial data provided by adjudicationDetermination.jsp for updating determination
    adjid: null,
    ptid: null,
    initData: {},
    requiresHiv1: true,
    requiresHiv2: false,
    adjUtil: {},

    initComponent : function()
    {
        this.items = [
            Ext4.create('LABKEY.adj.MakeDeterminationPanel', {
                adjid: this.adjid,
                ptid: this.ptid,
                initData: this.initData,
                requiresHiv1: this.requiresHiv1,
                requiresHiv2: this.requiresHiv2,
                adjUtil: this.adjUtil
            })
        ];

        this.callParent();
    }
});

Ext4.define('LABKEY.adj.MakeDeterminationPanel', {
    extend: 'Ext.form.Panel',

    labelAlign: "top",
    border: false,
    padding: 10,
    layout: {
        type: 'vbox',
        defaultMargins: {
            bottom: 3
        }
    },

    HIV_INFECTION_OPTIONS: ["Yes", "No", "Final Determination is Inconclusive", "Further Testing Required"],

    initComponent: function()
    {
        var items = [this.getCaseSummaryView()];
        if (this.requiresHiv1)
        {
            items.push(this.initHivItemsPanel(1, 'HIV-1', 'Hiv1Infected', 'Hiv1Comment'));
        }
        if (this.requiresHiv2)
        {
            items.push(this.initHivItemsPanel(2, 'HIV-2', 'Hiv2Infected', 'Hiv2Comment'));
        }
        this.items = items;

        this.buttons = [
            this.getSubmitButton(),
            this.getCancelButton()
        ];

        this.callParent();
    },

    getCaseSummaryView : function()
    {
        if (!this.caseSummaryView)
        {
            this.caseSummaryView = Ext4.create('Ext.view.View', {
                tpl: new Ext4.XTemplate(
                    '<tpl if="adjid != undefined">',
                        '<div class="determ-form-header">Case Summary</div>',
                        '<div><span class="determ-form-label">Case ID:</span> {adjid}</div>',
                        '<div><span class="determ-form-label">Participant ID:</span> {ptid}</div>',
                    '</tpl>'
                ),
                data: {
                    adjid: this.adjid,
                    ptid: this.ptid
                }
            });
        }

        return this.caseSummaryView;
    },

    initHivItemsPanel : function(index, label, infFieldName, commFieldName)
    {
        var infDateVal = this.initData[infFieldName + 'Date'] != null ? this.adjUtil.formatDate(this.initData[infFieldName + 'Date']) : null,
            drawDateStoreRecord = this.adjUtil.drawDatesStore.findRecord('date', infDateVal),
            infDateRow = infDateVal != null && drawDateStoreRecord != null ? drawDateStoreRecord.get('row') : null;

        var infCombo = Ext4.create('Ext.form.field.ComboBox', {
            name: "statusHiv" + index,
            store: this.HIV_INFECTION_OPTIONS,
            fieldLabel: 'Is this subject ' + label + ' infected?',
            labelAlign: 'top',
            labelSeparator: '',
            allowBlank: false,
            editable: false,
            emptyText: "",
            width: 250,
            padding: '0 20px 0 0',
            value: this.initData[infFieldName]
        });

        var dateCombo = Ext4.create('Ext.form.field.ComboBox', {
            id: "dateInfHiv" + index + "-combo",
            name: "dateInfHiv" + index,
            store: this.adjUtil.drawDatesStore,
            fieldLabel: 'What is the date of the diagnosis?',
            labelAlign: 'top',
            labelSeparator: '',
            disabled: !Ext4.isDefined(this.initData[infFieldName]) || this.initData[infFieldName] != 'Yes',
            editable: false,
            valueField: 'row',
            displayField: 'date',
            emptyText: "",
            width: 230,
            value: infDateRow
        });

        infCombo.on('change', function(combo, newValue, oldValue)
        {
            var yesSelected = newValue == 'Yes';
            dateCombo.setDisabled(!yesSelected);
            if (!yesSelected)
                dateCombo.setValue(null);
        });

        return Ext4.create('Ext.panel.Panel', {
            border: false,
            items: [{
                xtype: 'box',
                html: '<div class="determ-form-header determ-form-spacer">' + label + ' Infection Status</div>'
            },{
                xtype: 'fieldcontainer',
                layout: 'hbox',
                items: [infCombo, dateCombo]
            },
            {
                xtype: "textarea",
                name: "commentHiv" + index,
                fieldLabel: 'Comments:',
                labelAlign: 'top',
                labelSeparator: '',
                width: 500,
                value: this.initData[commFieldName]
            }]
        });
    },

    getSubmitButton : function()
    {
        if (!this.submitButton)
        {
            this.submitButton = Ext4.create('Ext.button.Button', {
                text: "Submit",
                formBind: true,
                scope: this,
                handler: this.validateForm
            });
        }

        return this.submitButton;
    },

    submitForm : function ()
    {
        // disable the Submit and Cancel buttons
        this.getSubmitButton().disable();
        this.getCancelButton().disable();

        var data = this.getForm().getValues(),
            hiv1Infection = data.statusHiv1 == 'Yes',
            hiv1FurtherTesting = data.statusHiv1 == 'Further Testing Required',
            hiv2Infection = data.statusHiv2 == 'Yes',
            hiv2FurtherTesting = data.statusHiv2 == 'Further Testing Required';

        var jsonData = {
            RowId: this.initData.RowId,
            CaseId: this.adjid,
            Status: hiv1FurtherTesting || hiv2FurtherTesting ? 'pending' : 'completed',
            Adjudicator: LABKEY.Security.currentUser.id,
            // to be set below if this container requires HIV-1 determination
            Hiv1Infected: null, Hiv1InfVisit: null, Hiv1Comment: null,
            // to be set below if this container requires HIV-2 determination
            Hiv2Infected: null, Hiv2InfVisit: null, Hiv2Comment: null
        };

        if (this.requiresHiv1)
        {
            jsonData.Hiv1Infected = data.statusHiv1;
            jsonData.Hiv1InfVisit = !hiv1Infection ? null : data.dateInfHiv1;
            jsonData.Hiv1Comment = data.commentHiv1;
        }

        if (this.requiresHiv2)
        {
            jsonData.Hiv2Infected = data.statusHiv2;
            jsonData.Hiv2InfVisit = !hiv2Infection ? null : data.dateInfHiv2;
            jsonData.Hiv2Comment = data.commentHiv2;
        }

        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'makeDetermination'),
            method: 'POST',
            jsonData: jsonData,
            scope: this,
            success: function (response)
            {
                var data = Ext4.decode(response.responseText);

                if (data.caseUpdated)
                {
                    window.location = LABKEY.ActionURL.buildURL('adjudication', 'adjudicationReview', null, {
                        adjid: data.caseId,
                        isAdminReview: false
                    });
                }
                else
                {
                    window.location = LABKEY.ActionURL.buildURL('adjudication', 'adjudicationDetermination', null, {
                        adjid: this.adjid
                    });
                }
            },
            failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options)
            {
                this.getSubmitButton().enable();
                this.getCancelButton().enable();
                Ext4.Msg.alert("Failure", "Determination failed: " + (json.exception || response.statusText));
            })
        });
    },

    confirmInconslusiveStatus : function()
    {
        Ext4.Msg.confirm(
            'Confirm Inconclusive Status',
            'Note: a determination of Inconclusive should only be made if no additional re-draws can be obtained from the participant. Continue?',
            function(btnId)
            {
                if (btnId == 'yes')
                {
                    this.submitForm();
                }
            },
            this
        );
    },

    validateHIVStatusValues : function(status, infDate, comment, display)
    {
        var messages = [],
            hasStatus = Ext4.isDefined(status) && status != null && status != "",
            hasInfDate = Ext4.isDefined(infDate) && infDate != null && infDate != "",
            hasComment = Ext4.isDefined(comment) && comment != null && comment != "";

        // status must be set and if 'Yes' must have a date of diagnosis
        if (!hasStatus)
        {
            messages.push("No value selected for " + display + " determination.");
        }
        else if (status === "Yes" && !hasInfDate)
        {
            messages.push("No value selected for date of diagnosis of " + display + ".");
        }
        else if (status != "Yes" && hasInfDate)
        {
            messages.push("Only select date of diagnosis if you answered 'Yes' for " + display + " infection.");
        }
        // comment required for 'Further Testing Required' and 'Final Determination is Inconclusive' status
        if (hasStatus && status != 'Yes' && status != 'No' && !hasComment)
        {
            messages.push("Comment required for " + display + " status of '" + status + "'.");
        }
        // comment required for data of diagnosis that is not the earliest date in the combo
        if (hasInfDate && infDate != this.adjUtil.adjDrawDates[0]["row"] && !hasComment)
        {
            messages.push("Comment required " + display + " date of diagnosis that is not the earliest draw date.");
        }

        return messages;
    },

    validateForm : function()
    {
        var values = this.getForm().getValues(),
            hasInconclusiveStatus = values.statusHiv1 == 'Final Determination is Inconclusive' || values.statusHiv2 == 'Final Determination is Inconclusive',
            messages = [];

        if (this.requiresHiv1)
        {
            messages = messages.concat(this.validateHIVStatusValues(values.statusHiv1, values.dateInfHiv1, values.commentHiv1, 'HIV-1'));
        }
        if (this.requiresHiv2)
        {
            messages = messages.concat(this.validateHIVStatusValues(values.statusHiv2, values.dateInfHiv2, values.commentHiv2, 'HIV-2'));
        }

        if (messages.length > 0)
        {
            Ext4.Msg.show({
                title: "Error",
                msg: messages.join('<br/>'),
                buttons: Ext4.Msg.OK,
                icon: Ext4.Msg.ERROR
            });
        }
        else if (hasInconclusiveStatus)
        {
            this.confirmInconslusiveStatus();
        }
        else
        {
            this.submitForm();
        }
    },

    getCancelButton : function()
    {
        if (!this.cancelButton)
        {
            this.cancelButton = Ext4.create('Ext.button.Button', {
                text: "Cancel",
                scope: this,
                handler: function () {
                    this.up('window').close();
                }
            });
        }

        return this.cancelButton;
    }
});