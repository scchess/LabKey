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
Ext4.define('CNPRC_EHR.panel.WeightGraphPanel', {
    extend: 'EHR.panel.WeightGraphPanel',
    alias: 'widget.cnprc_ehr-weightgraphpanel',

    getGraphConfig: function(results){
        return {
            xtype: 'ldk-graphpanel',
            title: this.showRawData ? 'Graph' : null,
            style: 'margin-bottom: 30px',
            plotConfig: {
                results: results,
                title: 'Weight: ' + this.subjectId,
                height: 400,
                width: 900,
                yLabel: 'Weight (kg)',
                xLabel: 'Date',
                xField: 'date',
                grouping: ['Id'],
                layers: [{
                    y: 'weight',
                    hoverText: function(row){
                        var lines = [];

                        lines.push('Date: ' + row.date.format(LABKEY.extDefaultDateFormat));
                        // always show two decimal places for weights
                        lines.push('Weight: ' + Number(Math.round(row.weight+'e2')+'e-2').toFixed(2) + ' kg');
                        lines.push('Latest Weight: ' + Number(Math.round(row.LatestWeight+'e2')+'e-2').toFixed(2) + ' kg');
                        if(row.LatestWeightDate)
                            lines.push('Latest Weight Date: ' + row.LatestWeightDate.format(LABKEY.extDefaultDateFormat));
                        if(row.PctChange)
                            lines.push('% Change From Current: '+row.PctChange + '%');
                        lines.push('Interval (Months): ' + row.IntervalInMonths);

                        return lines.join('\n');
                    },
                    name: 'Weight'
                }]
            }
        }
    },

    getQWPConfig: function(){
        return {
            xtype: 'ldk-querypanel',
            title: 'Raw Data',
            style: 'margin: 5px;',
            queryConfig: {
                frame: 'none',
                containerPath: this.containerPath,
                schemaName: 'study',
                queryName: 'weightPercentChange',
                sort: 'id,-date',
                failure: LDK.Utils.getErrorCallback(),
                filterArray: [LABKEY.Filter.create('Id', this.subjectId, LABKEY.Filter.Types.EQUAL)]
            }
        }
    }
});