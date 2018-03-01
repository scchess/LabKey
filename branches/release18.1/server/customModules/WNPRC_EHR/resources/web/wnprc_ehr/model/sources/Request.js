/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('WNPRC_Request', {
    allQueries: {
        account: {
            shownInGrid: true,
            columnConfig: {
                displayAfterColumn: 'project'
            }
        },
        //Category
        type: {
            columnConfig: {
                displayAfterColumn: "servicerequested"
            }
        },
        collectedBy: {
            columnConfig: {
                displayAfterColumn: "collectionMethod"
            }
        },
        dateReviewed: {
            hidden: true
        },
        clinremark: {
            hidden: true
        },
        reviewedBy: {
            hidden: true
        },
        servicerequested: {
            lookup: {
                queryName: 'filter_labwork' // Use the filter_labwork query to filter out disabled options.
            }
        },
        sampletype: {
            hidden: false,
            shownInGrid: true
        }
    }
});