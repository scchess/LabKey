/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('CNPRC_EHR.grid.CNPRC_RoundsRemarksGridPanel', {
    extend: 'EHR.grid.RoundsRemarksGridPanel',
    alias: 'widget.cnprc_ehr-cnprc_roundsremarksgridpanel',

    getRowEditorPlugin: function(){
        if (this.rowEditorPlugin)
            return this.rowEditorPlugin;

        this.rowEditorPlugin = Ext4.create('CNPRC_EHR.plugin.CNPRC_ClinicalRemarksRowEditor', {
            cmp: this
        });

        return this.rowEditorPlugin;
    }
});