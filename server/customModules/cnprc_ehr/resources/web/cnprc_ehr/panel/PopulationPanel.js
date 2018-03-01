/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg filterArray
 * @cfg colFields
 * @cfg rowField
 */
Ext4.define('CNPRC_EHR.panel.PopulationPanel', {
    extend: 'EHR.panel.PopulationPanel',
    alias: 'widget.cnprc-ehr-populationpanel',

    getInitialValueMap: function() {
        return {
            "Id/ageClass/label":["Infant","Juvenile","Adult","Geriatric"]
        };
    },

    onLoad: function(){
        var target = this.down('#populationPanel');
        var toAdd = [];

        if (!this.rawData || !this.rawData.rowCount){
            target.removeAll();
            target.add({
                html: 'No animals were found'
            });
            return;
        }

        //header rows.  first add 2 for rowname/total
        var rows = [];
        var repeats = 1;
        var style =  'text-align: right;margin-right: 3px;margin-left: 3px;margin-bottom:3px;';
        var styleHeader = 'text-align: center;margin-right: 3px;margin-left: 3px;margin-bottom:3px;';
        Ext4.each(this.colFields, function(colName, idx){
            var colspan = this.getColSpan(this.colFields, idx);

            rows.push({html: ''});
            rows.push({html: ''});

            var valueArray = this.valueMap[colName];
            for (var i=0;i<repeats;i++){
                Ext4.each(valueArray, function(header){
                    LDK.Assert.assertNotEmpty('Population panel has a blank header value for the column: ' + colName + '.  This probably indicates bad data.', header);
                    if (!header)
                        header = 'Unknown ' + colName;
                    rows.push({
                        html: header,
                        style: (colspan>1?styleHeader:style),
                        colspan: colspan
                    });
                }, this);
            }

            if (idx == 0) {
                rows.push({html: ''});
                rows.push({
                    html: 'Total',
                    style: 'border-bottom: solid 1px;' + styleHeader
                });

                var subHeaderStyle = 'border-bottom: solid 1px;' + (colspan>1?styleHeader:style);
                var subHeaderRow = this.getSubHeaderRowItems(valueArray, subHeaderStyle, colspan);
                Ext4.each(subHeaderRow, function(s) {
                    rows.push(s);
                });
            }

            repeats = valueArray ? repeats * valueArray.length : 0;
        }, this);

        //now append the data rows
        var colKeys = this.generateColKeys();
        var rowNames = this.valueMap[this.rowField];
        rowNames.sort();
        Ext4.each(rowNames, function(rowName){
            rowName = Ext4.isEmpty(rowName) ? 'Blank' : rowName;
            rows.push({
                html: rowName + ':',
                style: 'padding-left: 10px;padding-bottom:3px;padding-right: 5px;'
            });

            //total count
            var params = {
                schemaName: 'study',
                'query.queryName': 'Demographics'
            };
            params['query.' + this.rowField + '~eq'] = rowName;
            this.appendFilterParams(params);

            var url = LABKEY.ActionURL.buildURL('query', 'executeQuery', null, params);
            var totalValue = this.aggregateData.rowMap[rowName] ? this.aggregateData.rowMap[rowName].total : 0;
            rows.push(EHR.Utils.getFormattedRowNumber(totalValue, url));

            var parentData = this.aggregateData.rowMap[rowName] || {};
            Ext4.each(colKeys, function(key){
                var value = 0;
                if (parentData && parentData.colKeys && parentData.colKeys[key]) {
                    value = parentData.colKeys[key];
                }

                var params = {
                    schemaName: 'study',
                    'query.queryName': 'Demographics'
                };
                var tokens = key.split('<>');

                params['query.' + this.rowField + '~eq'] = rowName;
                Ext4.each(this.colFields, function(colField, idx){
                    var meta = this.getMetadata(colField);
                    var fk = meta.displayField || meta.fieldKeyPath;
                    params['query.' + fk + '~eq'] = tokens[idx];
                }, this);

                this.appendFilterParams(params);
                var url = LABKEY.ActionURL.buildURL('query', 'executeQuery', null, params);
                rows.push(EHR.Utils.getFormattedRowNumber(value, url));
            }, this);
        }, this);

        toAdd.push({
            layout: {
                type: 'table',
                columns: this.getTotalColumns(),
                tdAttrs: {
                    style: {
                        width: '70px'
                    }
                }
            },
            defaults: {
                border: false,
                style: 'text-align: center;padding: 4px'
            },
            items: rows
        });

        target.removeAll();
        target.add(toAdd);
    },

    getSubHeaderRowItems: function(valueArray, style, colspan) {
        var subHeaders = {Infant: "0 - 6 mos", Juvenile: "6 mos - 3.5 yrs", Adult: "3.5 - 15 yrs", Geriatric: "15+ yrs"},
            items = [];

        Ext4.each(valueArray, function(value) {
            items.push({
                html: subHeaders[value] || "&nbsp;",
                style: style,
                colspan: colspan
            });
        });

        return items;
    }
});