/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.window.AddClinicalCasesWindowWithAdmitType', {
    extend: 'EHR.window.AddClinicalCasesWindow',

    initComponent: function () {
        Ext4.applyIf(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Add Open ' + this.caseCategory + ' Cases',
            border: true,
            bodyStyle: 'padding: 5px',
            width: 420,
            defaults: {
                width: 400,
                labelWidth: 150,
                border: false
            },
            items: [{
                html: 'This helper allows you to query open cases and add records for these animals.' +
                (this.allowNoSelection ? '  Leave blank to load all areas.' : ''),
                style: 'padding-bottom: 10px;'
            }, {
                xtype: 'ehr-areafield',
                itemId: 'areaField'
            }, {
                xtype: 'ehr-roomfield',
                itemId: 'roomField'
            }, {
                xtype: 'ehr-admittypefield',
                itemId: 'admitTypeField'
            }, {
                xtype: 'textarea',
                fieldLabel: 'Animal(s)',
                itemId: 'idField'
            }, {
                xtype: 'ehr-vetfieldcombo',
                fieldLabel: 'Assigned Vet (blank for all)',
                itemId: 'assignedVet',
                hidden: !this.showAssignedVetCombo,
                checked: true
            }, {
                xtype: 'xdatetime',
                fieldLabel: 'Date',
                value: new Date(),
                itemId: 'date'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Entered By',
                value: LABKEY.Security.currentUser.displayName,
                itemId: 'performedBy'
            }, {
                xtype: 'checkbox',
                fieldLabel: 'Exclude Animals w/ Obs Entered Today',
                itemId: 'excludeToday',
                checked: true
            }, {
                xtype: 'checkbox',
                fieldLabel: 'Include Cases Closed For Review',
                hidden: !this.showAllowOpen,
                itemId: 'includeOpen',
                checked: false
            }, {
                xtype: 'checkbox',
                hidden: !this.allowReviewAnimals,
                fieldLabel: 'Review Animals First',
                itemId: 'reviewAnimals'
            }],
            buttons: [{
                text: 'Submit',
                itemId: 'submitBtn',
                scope: this,
                handler: this.getCases
            }, {
                text: 'Close',
                scope: this,
                handler: function (btn) {
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);

        if (this.templateName) {
            LABKEY.Query.selectRows({
                schemaName: 'ehr',
                queryName: 'formtemplates',
                filterArray: [
                    LABKEY.Filter.create('title', this.templateName),
                    LABKEY.Filter.create('formtype', 'Clinical Observations'),
                    LABKEY.Filter.create('category', 'Section')
                ],
                scope: this,
                success: function (results) {
                    LDK.Assert.assertTrue('Unable to find template: ' + this.templateName, results.rows && results.rows.length == 1);

                    this.obsTemplateId = results.rows[0].entityid;
                },
                failure: LDK.Utils.getErrorCallback()
            });
        }
    },
    getCasesFilterArray: function(){
        var filterArray = this.getBaseFilterArray();
        var admitTypeField = this.down('#admitTypeField').getValue() || [];
        filterArray.push(LABKEY.Filter.create('admitType', admitTypeField.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF));
        filterArray.push(LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK));

        return filterArray;
    }
});

EHR.DataEntryUtils.registerGridButton('ADDCNPRCCLINICALCASEBUTTON', function(config){
    return Ext4.Object.merge({
        text: 'Add Open Cases',
        tooltip: 'Click to automatically add SOAP notes based on open cases',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            if(!grid.store || !grid.store.hasLoaded()){
                console.log('no store or store hasnt loaded');
                return;
            }

            var cellEditing = grid.getPlugin('cellediting');
            if(cellEditing)
                cellEditing.completeEdit();

            Ext4.create('EHR.window.AddClinicalCasesWindowWithAdmitType', {
                targetStore: grid.store
            }).show();
        }
    }, config);
});