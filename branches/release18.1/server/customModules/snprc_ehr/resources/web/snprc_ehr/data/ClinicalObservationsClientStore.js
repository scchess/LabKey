/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('SNPRC_EHR.data.ClinicalObservationsClientStore', {
    extend: 'EHR.data.DataEntryClientStore',

    constructor: function(){
        this.callParent(arguments);

        //this.observationTypesStore = EHR.DataEntryUtils.getObservationTypesStore();
    }
});
