/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * The default metadata applied to all queries when using getTableMetadata().
 * This is the default metadata applied to all queries when using getTableMetadata().  If adding attributes designed to be applied
 * to a given query in all contexts, they should be added here
 */
EHR.model.DataModelManager.registerMetadata('Default', {
    allQueries: {
        projectCode: {
            xtype: 'ehr-projectcodeentryfield',
            editorConfig: {},
            shownInGrid: true,
            useNull: true,
            lookup: {
                columns: 'projectCode'
            }
        }
    },
    byQuery: {
        'study.clinremarks': {
            p2: {
                formEditorConfig: {
                    xtype: 'cnprc_ehr-plantextarea'
                },
                height: 75
            }
        }
    }
});