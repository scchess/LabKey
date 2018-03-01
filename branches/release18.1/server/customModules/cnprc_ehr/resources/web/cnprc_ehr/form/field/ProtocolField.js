/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg onlyIncludeProtocolsWithAssignments
 */
Ext4.define('CNPRC_EHR.form.field.ProtocolField', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.cnprc_ehr-protocolfield',

    fieldLabel: 'AUCAAC Protocol',
    editable: true,
    caseSensitive: false,
    anyMatch: true,
    forceSelection: true,
    matchFieldWidth: false,

    onlyIncludeProtocolsWithAssignments: false,

    initComponent: function(){
        Ext4.apply(this, {
            displayField: 'title',
            valueField: 'protocol',
            queryMode: 'local',
            store: this.getStoreCfg()
        });

        this.listConfig = this.listConfig || {};
        Ext4.apply(this.listConfig, {
            innerTpl:this.getInnerTpl(),
            getInnerTpl: function(){
                return this.innerTpl;
            },
            style: 'border-top-width: 1px;' //this was added in order to restore the border above the boundList if it is wider than the field
        });

        this.callParent(arguments);
    },

    //can be overridden by child modules
    getInnerTpl: function(){
        // return ['<span style="white-space:nowrap;">{[values["displayName"] + " " + (values["investigatorId/lastName"] ? "(" + (values["investigatorId/lastName"] ? values["investigatorId/lastName"] : "") + ")" : "")]}&nbsp;</span>'];
        return ['<span style="white-space:nowrap;">{[values["protocol"] + " - " + values["title"]]}&nbsp;</span>'];
    },

    getStoreCfg: function(){
        var ctx = EHR.Utils.getEHRContext();

        var storeCfg = {
            type: 'labkey-store',
            containerPath: ctx ? ctx['EHRStudyContainer'] : null,
            schemaName: 'cnprc_ehr',
            queryName: 'protocol',
            columns: 'protocol,title,piPersonId',
            filterArray: [
                LABKEY.Filter.create('protocolEnddate', '-0d', LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL)
            ],
            sort: 'protocol',
            autoLoad: true
        };

        // if (this.onlyIncludeProtocolsWithAssignments){
        //     storeCfg.filterArray.push(LABKEY.Filter.create('activeAnimals/TotalActiveAnimals', 0, LABKEY.Filter.Types.GT));
        // }

        if (this.storeConfig){
            Ext4.apply(storeCfg, this.storeConfig);
        }

        if (this.filterArray){
            storeCfg.filterArray = storeCfg.filterArray.concat(this.filterArray);
        }

        return storeCfg;
    }
});