/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg demographicsFilterArray
 * @cfg filterArray
 */
Ext4.define('CNPRC_EHR.panel.ClinicalSummaryPanel', {
    extend: 'EHR.panel.BasicAggregationPanel',
    alias: 'widget.cnprc-ehr-clinicalsummarypanel',

    initComponent: function(){
        Ext4.apply(this, {
            style: 'padding: 5px',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                html: '<b>Clinical Summary:</b>'
            },{
                html: '<hr>'
            },{
                itemId: 'childPanel',
                defaults: {
                    border: false
                },
                items: [{
                    html: 'Loading...'
                }]
            }]
        });

        this.callParent(arguments);

        this.loadData();
    },

    loadData: function(){
        LABKEY.Query.selectRows({
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'activeCases',
            columns: ['Id', 'date', 'admitType'].join(','),
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                this.caseData = this.aggregateResults(results, 'admitType');
                this.demographicsData = this.caseData;
                if(this.demographicsData)
                    this.demographicsData.rowCount = this.demographicsData.total;  // somewhat ugly hack to avoid changing BasicAggregationPanel too much; NOT using Demographics data here
                this.onLoad();
            }
        });
    },

    onLoad: function(){
        var target = this.down('#childPanel');
        target.removeAll();

        var cfg = {
            defaults: {
                border: false
            },
            items: []
        };

        var cases = this.appendSection('Open Cases', this.caseData, 'admitType/description', 'eq');
        if (cases)
            cfg.items.push(cases);

        if (!cfg.items.length){
            cfg.items.push({
                html: 'There are no open cases or problems'
            });
        }
        target.add(cfg);
    },

    // Overrides function in BasicAggregationPanel
    generateUrl: function(val, key, data, filterCol, operator){
        if (!val)
            return null;

        operator = operator || 'eq';

        var params = {
            schemaName: 'study',
            'query.queryName': 'activeCases'
        };
        params = this.appendFilterParams(params);
        params['query.' + filterCol + '~' + operator] = key;

        return LABKEY.ActionURL.buildURL('query', 'executeQuery', null, params);
    }
});