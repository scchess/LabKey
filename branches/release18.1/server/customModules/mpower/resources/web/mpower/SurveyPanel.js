/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('LABKEY.ext4.MPowerSurveyPanel', {
    extend: 'LABKEY.ext4.SurveyPanel',
    alias: 'widget.mpower_surveypanel',

    constructor: function (config)
    {
        Ext4.applyIf(config, {
            itemId          : 'SurveyFormPanel', // used by sidebar section click function
            isSubmitted     : false,
            canEdit         : true,
            disableAutoSave : true,
            updateUrl       : LABKEY.ActionURL.buildURL('mpower', 'saveSurveyResponse.api'),
            forceLowerCaseNames : false,
            saveSubmitMode      : 'save/cancel'
        });
        this.callParent([config]);
    },

    initComponent: function ()
    {
        this.callParent();
    }
});
