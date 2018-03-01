/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('CNPRC_EHR.panel.HousingSummaryPanel', {
    extend: 'EHR.panel.HousingSummaryPanel',
    alias: 'widget.cnprc-ehr-housingsummarypanel',

    nounSingular: 'Area',
    nounPlural: 'Areas',
    headerNames:  ['Type', 'Animal Count', '% of Total'],
    cageUsagePanelColumnCount: 8,
    usageTitleHTML: '<b data-toggle="tooltip" title="This section is a report of cages and species by location. Note that there ' +
    'can be multiple animals in a cage, so the species count and empty cage count will not necessarily equal total cage count.">Area Usage:</b><hr>',

    getAvailableCagesUrlParams: function (area) {
        var urlParams = {
            schemaName: 'ehr_lookups',
            'query.queryName': 'availableCages',
            'query.isAvailable~eq': true,
            'query.sort': 'cage'
        };
        urlParams['query.room/' + this.nounSingular.toLowerCase() + '~eq'] = area;
        urlParams['query.indoorOutdoorFlag~eq'] = 'I';

        return urlParams;
    },

    addAdditionalCells: function(cells,row){
        cells.push(EHR.Utils.getFormattedRowNumber(row.getDisplayValue('totalMMUAnimals'),null,false));
        cells.push(EHR.Utils.getFormattedRowNumber(row.getDisplayValue('totalCMOAnimals'),null,false));
        cells.push(EHR.Utils.getFormattedRowNumber(row.getDisplayValue('totalMCYAnimals'),null,false));
        cells.push(EHR.Utils.getFormattedRowNumber(row.getDisplayValue('totalOtherAnimals'),null,false));
    },

    getCageUsageHeaderNames: function () {
        return [this.nounSingular, 'Total Cages', 'Empty Cages', 'MMU Count', 'CMO Count', 'MCY Count', 'Unknown', '% Used'];
    }

});