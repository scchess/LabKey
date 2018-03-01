/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('CNPRC_EHR.plugin.CNPRC_ClinicalRemarksRowEditor', {
    extend: 'EHR.plugin.ClinicalRemarksRowEditor',
    alias: 'widget.cnprc_ehr-cnprc_clinicalremarksroweditor',

    getDetailsPanelCfg: function(){
        return {
            xtype: 'cnprc_ehr-animaldetailscaseextendedpanel',
            itemId: 'detailsPanel',
            className: 'ExtendedAnimalDetailsRoundsFormSection'
        }
    },
    getObservationPanelCfg: function(){
        var store = this.cmp.dataEntryPanel.storeCollection.getClientStoreByName('Clinical Observations');
        LDK.Assert.assertNotEmpty('Observations store not found', store);

        return {
            xtype: 'cnprc_ehr-cnprc_observationsroweditorgridpanel',
            itemId: 'observationsPanel',
            remarkStore: this.cmp.store,
            width: 500,
            store: store
        };
    }
});