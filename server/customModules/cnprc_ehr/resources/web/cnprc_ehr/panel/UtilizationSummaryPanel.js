/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @param filterArray
 */
Ext4.define('CNPRC_EHR.panel.UtilizationSummaryPanel', {
    extend: 'EHR.panel.UtilizationSummaryPanel',
    alias: 'widget.cnprc-ehr-utilizationsummarypanel',

    loadData: function(){

        //find animal count
        LABKEY.Query.selectRows({
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'DemographicsUtilization',
            columns: ['Id', 'Id/demographicsUtilization/fundingCategory'].join(','),
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: function(results){
                this.demographicsData = results;
                this.usageCategoryData = this.aggregateResults(results, 'Id/demographicsUtilization/fundingCategory');
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

        var item = this.appendSection('By Category', this.usageCategoryData, 'Id/demographicsUtilization/fundingCategory', 'eq');
        if (item)
            cfg.items.push(item);

        if (!cfg.items.length){
            cfg.items.push({
                html: 'No records found'
            });
        }
        target.add(cfg);
    }
});
