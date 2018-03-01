/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created: 2-22-2-2017  R.Blasa
Ext4.define('onprc_ehr.panel.NarrowSnapshotPanel', {
    extend:'onprc_ehr.panel.SmallFormSnapshotPanel',
    alias: 'widget.onprc_ehr-narrowsnapshotpanel',

    showLocationDuration: false,

    minWidth: 800,

    initComponent: function(){
        this.defaultLabelWidth = 120;
        this.callParent();
    },

    getItems: function(){
        var items = this.getBaseItems();

        //combine the first and second columns
        var firstCol = items[0].items[1].items[0];
        var secondCol = items[0].items[1].items[1];
        var thirdCol = items[0].items[1].items[2];
        items[0].items[1].items.remove(secondCol);

        firstCol.columnWidth = 0.45;
        thirdCol.columnWidth = 0.55;

        firstCol.items = firstCol.items.concat(secondCol.items);

        var extended = this.getExtendedItems();
        thirdCol.items = thirdCol.items.concat(extended[0].items[1].items[0].items);

        return items;
    }
});