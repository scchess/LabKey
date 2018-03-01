/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * @param subjectId
 */
Ext4.define('CNPRC_EHR.panel.AnimalDetailsCaseExtendedPanel', {
    extend: 'EHR.panel.AnimalDetailsExtendedPanel',
    alias: 'widget.cnprc_ehr-animaldetailscaseextendedpanel',

    appendCases: function(toSet, results){
        var dates = [];
        var reasons = [];
        var daysSinceAdmit;

        if (results){
            Ext4.each(results, function(row){

                if(row.enddate == null) { //open case
                    reasons.push(row.problem);
                    dates.push(LDK.ConvertUtils.parseDate(row.date));
                }

            }, this);

            //sort descending
            if(dates.length > 1) {
                dates.sort(function (a, b) {
                    return new Date(b.date) - new Date(a.date);
                });
            }
            var d1 = LDK.ConvertUtils.parseDate(dates[0]);
            var d2 = Ext4.Date.clearTime(new Date(), true);
            var days = Ext4.Date.getElapsed(d2, d1);
            days = days / (1000 * 60 * 60 * 24);
            days = Math.floor(days);

            toSet['admitDate'] = d1;
            toSet['admitReason'] = reasons.length ? reasons.join(',<br>') : 'None';
            toSet['daysSinceAdmit'] = days;
        }
    },

    appendAssignmentsAndGroups: function(toSet, record){
        toSet['assignmentsAndGroups'] = null;

        if (this.redacted)
            return;

        var values = [];

        if (record.getActiveAssignments() && record.getActiveAssignments().length){
            Ext4.each(record.getActiveAssignments(), function(row){
                if(row.enddate == null) {
                    var val = row.projectCode + " (" + row.assignmentStatus + ")";
                    if (val)
                        values.push(val);
                }
            }, this);
        }
        toSet['assignmentsAndGroups'] = values.length ? values.join('<br>') :  'None';
    },

    appendFlags: function(toSet, results){
        var values = [];
        if (results){
            Ext4.each(results, function(row){
                if(row.enddate == null) {
                    var val = row['flag/value'];
                    var text = val;

                    if (text)
                        text = '<span style="background-color:#fffd76">' + text + '</span>';

                    if (text)
                        values.push(text);
                }
            }, this);

            if (values.length) {
                values = Ext4.unique(values);
            }
        }

        toSet['flags'] = values.length ? '<a onclick="EHR.Utils.showFlagPopup(\'' + this.subjectId + '\', this);">' + values.join('<br>') + '</div>' : null;
    },
    getItems: function(){
        return [{
            layout: 'column',
            defaults: {
                border: false,
                bodyStyle: 'padding-right: 20px;'
            },
            items: [{
                xtype: 'container',
                width: 380,
                defaults: {
                    xtype: 'displayfield',
                    labelWidth: this.defaultLabelWidth
                },
                items: [{
                    fieldLabel: 'Id',
                    name: 'animalId'
                },{
                    fieldLabel: 'Location',
                    name: 'location'
                },{
                    fieldLabel: 'Gender',
                    name: 'gender'
                },{
                    fieldLabel: 'Species',
                    name: 'species'
                },{
                    fieldLabel: 'Age',
                    name: 'age'
                },{
                    fieldLabel: 'Project Code(s)',
                    name: 'assignmentsAndGroups'
                }]
            },{
                xtype: 'container',
                width: 350,
                defaults: {
                    xtype: 'displayfield'
                },
                items: [{
                    fieldLabel: 'Status',
                    name: 'calculated_status'
                },{
                    fieldLabel: 'Flags',
                    name: 'flags'
                },{
                    fieldLabel: 'Weight',
                    name: 'weights'
                }]
            },{
                xtype: 'container',
                width: 350,
                defaults: {
                    xtype: 'displayfield'
                },
                items: [{
                    fieldLabel: 'Admit Reason',
                    name: 'admitReason'
                },{
                    fieldLabel: 'Admit Date',
                    name: 'admitDate'
                },{
                    fieldLabel: 'Days Since Admit',
                    name: 'daysSinceAdmit'
                }]
            },{
                xtype: 'container',
                width: 350,
                defaults: {
                    xtype: 'displayfield'
                },
                items: [{
                    xtype: 'ldk-linkbutton',
                    style: 'margin-top: 10px;',
                    scope: this,
                    text: '[Show Full Hx]',
                    handler: function(){
                        if (this.subjectId){
                            EHR.window.ClinicalHistoryWindow.showClinicalHistory(null, this.subjectId, null);
                        }
                        else {
                            console.log('no id');
                        }
                    }
                },{
                    xtype: 'ldk-linkbutton',
                    style: 'margin-top: 5px;',
                    scope: this,
                    text: '[Show Recent SOAPs]',
                    handler: function(){
                        if (this.subjectId){
                            EHR.window.RecentRemarksWindow.showRecentRemarks(this.subjectId);
                        }
                        else {
                            console.log('no id');
                        }
                    }
                },{
                    xtype: 'ldk-linkbutton',
                    style: 'margin-top: 5px;',
                    scope: this,
                    text: '[Manage Treatments]',
                    hidden: EHR.Security.hasClinicalEntryPermission() && !EHR.Security.hasPermission(EHR.QCStates.COMPLETED, 'update', [{schemaName: 'study', queryName: 'Treatment Orders'}]),
                    handler: function(){
                        if (this.subjectId){
                            Ext4.create('EHR.window.ManageTreatmentsWindow', {animalId: this.subjectId}).show();
                        }
                        else {
                            console.log('no id');
                        }
                    }
                },{
                    xtype: 'ldk-linkbutton',
                    style: 'margin-top: 5px;margin-bottom:10px;',
                    scope: this,
                    text: '[Manage Cases]',
                    hidden: EHR.Security.hasClinicalEntryPermission() && !EHR.Security.hasPermission(EHR.QCStates.COMPLETED, 'update', [{schemaName: 'study', queryName: 'Cases'}]),
                    handler: function(){
                        if (this.subjectId){
                            Ext4.create('EHR.window.ManageCasesWindow', {animalId: this.subjectId}).show();
                        }
                        else {
                            console.log('no id');
                        }
                    }
                }]
            }]
        }];
    }
});
