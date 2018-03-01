/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * This is used within the RowEditor in the clinical rounds form
 *
 * @cfg observationFilterArray
 *
 */
Ext4.define('CNPRC_EHR.grid.CNPRC_ObservationsRowEditorGridPanel', {
    extend: 'EHR.grid.ObservationsRowEditorGridPanel',
    alias: 'widget.cnprc_ehr-cnprc_observationsroweditorgridpanel',

    getColumns: function() {
        return [{
            header: 'Category',
            dataIndex: 'category',
            editable: true,
            renderer: function (value, cellMetaData, record) {
                if (Ext4.isEmpty(value)) {
                    cellMetaData.tdCls = 'labkey-grid-cell-invalid';
                }

                return value;
            },
            editor: {
                xtype: 'labkey-combo',
                width: 200,
                editable: true,
                displayField: 'value',
                valueField: 'value',
                forceSelection: true,
                queryMode: 'local',
                anyMaych: true,
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr',
                    queryName: 'observation_types',
                    filterArray: this.observationFilterArray,
                    columns: 'value,editorconfig',
                    autoLoad: true
                }
            }
        },{
            header: 'Observation/Score',
            width: 150,
            editable: true,
            dataIndex: 'observation',
            renderer: function (value, cellMetaData, record) {
                if (Ext4.isEmpty(value) && ['Vet Attention'].indexOf(record.get('category')) == -1) {
                    cellMetaData.tdCls = 'labkey-grid-cell-invalid';
                }

                return value;
            },
            editor: {
                xtype: 'textfield'
            }
        },{
            header: 'Remark',
            width: 250,
            editable: true,
            dataIndex: 'remark',
            editor: {
                xtype: 'textfield'
            }
        }]
    }
});