/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('IrregularObservations', {
    allQueries: {
        feces: {
            xtype: 'checkcombo',
            hasOwnTpl: true,
            includeNullRecord: false,
            lookup: {
                schemaName:    'ehr_lookups',
                queryName:     'obs_feces',
                displayColumn: 'title',
                keyColumn:     'value'
            },
            editorConfig: {
                tpl:         null,
                multiSelect: true,
                separator:   ','
            },
            columnConfig: {
                width: 200
            }
        }
    }
});