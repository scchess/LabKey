/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Overrides the metadata for study.clinremarks 'p2' field applied in Default.js
 */
EHR.model.DataModelManager.registerMetadata('ClinicalRemarks', {
            byQuery: {
                'study.clinremarks': {
                    p2: {
                        formEditorConfig: {
                            xtype: 'textarea'
                        },
                        height: 75
                    }
                }
            }
        }
);