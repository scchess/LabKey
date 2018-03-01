/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('CNPRC_EHR.form.field.PlanTextArea', {
    extend: 'EHR.form.field.PlanTextArea',
    alias: 'widget.cnprc_ehr-plantextarea',

    getMostRecentP2: function(rec, cb, alwaysUseCallback){
        var date = rec.get('date') || new Date();
        var id = rec.get('Id');
        this.pendingIdRequest = id;

        LABKEY.Query.executeSql({
            schemaName: 'study',
            sql: 'SELECT c.Id, c.p2 as mostRecentP2, c.caseid FROM study.clinRemarks c WHERE (c.category != \'Replaced SOAP\' OR c.category IS NULL) AND c.p2 IS NOT NULL AND c.Id = \'' + rec.get('Id') + '\' ORDER BY c.date DESC LIMIT 1',
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                if (!alwaysUseCallback && id != this.pendingIdRequest){
                    console.log('more recent request, aborting');
                    return;
                }

                if (results && results.rows && results.rows.length && results.rows[0].mostRecentP2){
                    cb.call(this, results.rows[0], results.rows[0].Id);
                }
                else {
                    cb.call(this, null, id);
                }
            }
        });
    }
});