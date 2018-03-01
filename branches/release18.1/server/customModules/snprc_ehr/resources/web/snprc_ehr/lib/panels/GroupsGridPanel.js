/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupsGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.groups-grid-panel',
    id: 'groups-grid-panel',
    store: Ext4.create('AnimalGroupsStore'),
    marginTop: 25,
    setType: 'cellmodel',
    plugins: [
        {
            ptype: 'cellediting',
            clicksToEdit: 2
        }
    ],
    tbar: [
        {
            text: "Add",
            handler: function () {
                var store = this.up('grid').getStore();

                if (store.getCategory()) {
                    rec = store.add([{code: 0, categoryCode: store.getCategory(), sortOrder: 0}]);
                    this.up('grid').getView().select(rec, true, true);

                }

            }
        }
    ],
    columns: [
        {
            text: 'Code',
            dataIndex: 'code',
            hidden: true,
            hideable: false

        },
        {
            text: 'Category Code',
            dataIndex: 'categoryCode',
            hidden: true,
            hideable: false

        }, {
            text: 'Name',
            dataIndex: 'name',
            minWidth: 200,
            editor: {
                xtype: 'textfield'
            }
        }, {
            text: 'Date',
            dataIndex: 'date',
            xtype: 'datecolumn',
            format: 'M d, Y',
            editor: {
                xtype: 'datefield'
            }
        }, {
            text: 'End Date',
            dataIndex: 'endDate',
            minWidth: 150,
            xtype: 'datecolumn',
            format: 'M d, Y',
            editor: {
                xtype: 'datefield'
            }
        }, {
            text: 'Comment',
            dataIndex: 'comment',
            flex: 1,
            autoSizeColumn: true,
            editor: {
                xtype: 'textfield'
            }
        }, {
            text: 'Sort Order',
            dataIndex: 'sortOrder',
            minWidth: 150,
            editor: {
                xtype: 'numberfield',
                step: 1
            }
        }, {

            header: 'Actions',
            xtype: 'actioncolumn',
            items: [
                {
                    tooltip: 'Assign Animals',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var assignAnimalsToGroupWindow = Ext4.create("AssignAnimalsToGroupWindow").setGroup(record.get("code"));
                        if (!assignAnimalsToGroupWindow.getGroup()) {
                            Ext4.Msg.alert("Save first", 'Please submit to save this group first, before trying to assign Animals');
                            return;
                        }
                        assignAnimalsToGroupWindow.show();
                        assignAnimalsToGroupWindow.loadMembersStore();
                    },
                    iconCls: "add-btn"

                },
                {
                    tooltip: 'Delete',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var grid = this.up('grid');
                        grid.getStore().removeAt(rowIndex);
                        grid.getStore().sync({
                            failure: function () {
                                grid.getStore().load({
                                    params: {
                                        'categoryCode': grid.getStore().getCategory()
                                    }
                                });
                                Ext4.Msg.alert('Error', 'Unable to delete this group');
                            },
                        });

                    },
                    iconCls: "trash-btn"

                }
            ]
        }
    ],
    buttons: [
        {
            text: 'Submit',
            handler: function () {
                var self = this;
                this.up('grid').getStore().save({
                    success: function () {
                        self.up('grid').getStore().load({
                            params: {
                                'categoryCode': self.up('grid').getStore().getCategory()
                            }

                        });
                    },
                    failure: function () {
                        Ext4.MessageBox.alert("Something went Wrong!", "Unable to add/update Group(s)");
                    }

                });


            }
        }
    ]
});
