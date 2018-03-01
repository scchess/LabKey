/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg subjectId
 * @cfg showRawData
 * @cfg containerPath
 */
Ext4.define('CNPRC_EHR.panel.WeightSummaryPanel', {
    extend: 'EHR.panel.WeightSummaryPanel',
    alias: 'widget.cnprc_ehr-weightsummarypanel',

    getRoundedNumber: function (value) {
        // always show two decimal places
        return Number(Math.round(value+'e2')+'e-2').toFixed(2);
    }
});