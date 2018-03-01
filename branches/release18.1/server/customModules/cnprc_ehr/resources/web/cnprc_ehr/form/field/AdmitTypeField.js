/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.form.field.AdmitTypeField', {
    extend: 'Ext.ux.CheckCombo',
    alias: 'widget.ehr-admittypefield',
    fieldLabel: 'Admit Type',

    initComponent: function(){
        Ext4.apply(this, {
            expandToFitContent: true,
            queryMode: 'local',
            anyMatch: true,
            store: {
                type: 'labkey-store',
                schemaName: 'ehr_lookups',
                queryName: 'admit_type',
                columns: 'value,description',
                autoLoad: true
            },
            valueField: 'value',
            displayField: 'description'
        });

        if (!Ext4.isDefined(this.initialConfig.multiSelect)){
            this.multiSelect = true;
        }
        this.callParent();

        this.on('render', function(field){
            field.el.set({autocomplete: 'off'});
        });
    }
});