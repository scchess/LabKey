/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('LABKEY.adj.ManageAdjudicatorTeams', {

    extend: 'Ext.form.Panel',

    border: false,

    MAX_TEAM_MEMBERS: 2,

    initComponent : function()
    {
        this.items = [];

        this.comboNameToRowIdMap = {};

        this.callParent();

        LABKEY.Query.executeSql({
            schemaName: 'adjudication',
            sql: 'SELECT adjteam.RowId, adjuser.RowId AS UserId, adjuser.UserId.Email AS UserEmail, ' +
                'adjteam.TeamNumber, adjteam.Notify from adjudication.adjudicationuser AS adjuser ' +
                'LEFT JOIN adjudication.adjudicationteamuser AS adjteam ON adjuser.RowId = adjteam.AdjudicationUserId ' +
                'WHERE adjuser.RoleId.Name = \'Adjudicator\'',
            scope: this,
            success: function(data)
            {
                var adjudicators = [],
                    teamMembers = [],
                    existingTeamCount = {};

                // we want to display MAX_TEAM_MEMBERS assignment rows for each team
                for (var i = 1; i <= this.teamCount; i++)
                    existingTeamCount[i] = 0;

                // parse the existing team assignment and adjudicator data
                Ext4.each(data.rows, function(row)
                {
                    adjudicators.push(Ext4.clone(row));

                    if (row.TeamNumber != null)
                    {
                        existingTeamCount[row.TeamNumber]++;
                        teamMembers.push(Ext4.clone(row));
                    }
                }, this);

                // add placeholder assignment rows to fill the teams
                Ext4.Object.each(existingTeamCount, function(teamNum, count)
                {
                    if (count < this.MAX_TEAM_MEMBERS)
                    {
                        for (var i = count; i < this.MAX_TEAM_MEMBERS; i++)
                        {
                            teamMembers.push({
                                RowId: null,
                                UserId: null,
                                TeamNumber: teamNum,
                                Notify: true
                            });
                        }
                    }
                }, this);

                this.getAdjudicatorStore().loadRawData(adjudicators);
                this.getTeamStore().loadRawData(teamMembers);
                this.populateTeamAssignmentForm();
                this.add(this.getSaveButton());
            }
        });

        this.on('dirtychange', function(form, dirty)
        {
            this.getSaveButton().setDisabled(!dirty);
        });
    },

    getAdjudicatorStore : function()
    {
        if (!this.adjudicatorStore)
        {
            this.adjudicatorStore = Ext4.create('Ext.data.Store', {
                fields: ['UserId', 'UserEmail'],
                sorters: [{property: 'UserEmail'}],
                data: []
            });
        }

        return this.adjudicatorStore;
    },

    getTeamStore : function()
    {
        if (!this.teamStore)
        {
            this.teamStore = Ext4.create('Ext.data.Store', {
                fields: ['RowId', 'UserId', 'UserEmail', 'TeamNumber', 'Notify'],
                sorters: [
                    {property: 'TeamNumber'},
                    {
                        sorterFn: function(o1, o2)
                        {
                            if (o1.get('UserEmail') == o2.get('UserEmail'))
                                return 0;
                            else if (o1.get('UserEmail') == null || o1.get('UserEmail') == '')
                                return 1;
                            else if (o2.get('UserEmail') == null || o2.get('UserEmail') == '')
                                return -1;
                            else
                                return o1.get('UserEmail') > o2.get('UserEmail') ? 1 : -1;
                        }
                    }
                ],
                data: []
            });
        }

        return this.teamStore;
    },

    populateTeamAssignmentForm : function()
    {
        var currTeamNum = null,
            assignmentSlot = 0;

        Ext4.each(this.getTeamStore().getRange(), function(record)
        {
            var teamNum = record.get('TeamNumber'),
                isNewTeam = currTeamNum == null || currTeamNum != teamNum;

            this.add(Ext4.create('Ext.form.FieldContainer', {
                fieldLabel: isNewTeam ? 'Team ' + teamNum : ' ',
                labelSeparator: '',
                labelWidth: 65,
                padding: !isNewTeam ? '0 0 15px 0' : undefined,
                layout: 'hbox',
                items: [
                    this.createMemberAssignmentCombo(record, assignmentSlot),
                    this.createNotifyCheckbox(record, assignmentSlot)
                ]
            }));

            currTeamNum = teamNum;
            assignmentSlot++;
        }, this);
    },

    createMemberAssignmentCombo : function(record, assignmentSlot)
    {
        var name = 'team-assignment-' + assignmentSlot;
        this.comboNameToRowIdMap[name] = record.get('RowId');

        return Ext4.create('Ext.form.ComboBox', {
            width: 300,
            hideLabel: true,
            name: name,
            cls: 'team-assignment-position',
            assignmentSlot: assignmentSlot,
            store: this.getAdjudicatorStore(),
            editable: false,
            emptyText: 'Select Adjudicator...',
            trigger2Cls: 'x4-form-clear-trigger',
            onTrigger2Click: function() {
                this.clearValue();
            },
            queryMode: 'local',
            displayField: 'UserEmail',
            valueField: 'UserId',
            value: record.get('UserId'),
            listeners: {
                scope: this,
                change: this.memberAssignmentChange
            }
        });
    },

    memberAssignmentChange : function(combo, newValue, oldValue)
    {
        var values = this.getValues(false, false, false, true);

        var assignedUserIds = [];
        for (var i = 0; i < this.teamCount * this.MAX_TEAM_MEMBERS; i++)
        {
            if (values['team-assignment-' + i] != null)
                assignedUserIds.push(values['team-assignment-' + i]);
        }

        // check if the selected adjudicator is already assigned to another team
        var hasDuplicate = assignedUserIds.length != Ext4.Array.unique(assignedUserIds).length;
        if (hasDuplicate)
        {
            this.showErrorMsg('The selected adjudicator is already assigned to a team.');

            // reset to the previous value
            combo.setValue(oldValue);
        }
        else
        {
            var relatedCheckbox = combo.up('fieldcontainer').down('checkboxfield');
            relatedCheckbox.setDisabled(newValue == null);
            if (relatedCheckbox.isDisabled())
                relatedCheckbox.setValue(true);
        }
    },

    createNotifyCheckbox : function(record, assignmentSlot)
    {
        return Ext4.create('Ext.form.field.Checkbox', {
            name: 'team-notify-' + assignmentSlot,
            assignmentSlot: assignmentSlot,
            boxLabel: 'Send notifications',
            fieldLabel: ' ',
            labelSeparator: '',
            labelWidth: 25,
            disabled: record.get('UserId') == null || record.get('UserId') == '',
            inputValue: true,
            uncheckedValue: false,
            checked: record.get('Notify')
        });
    },

    getSaveButton : function()
    {
        if (!this.saveBtn)
        {
            this.saveBtn = Ext4.create('Ext.button.Button', {
                text: 'Save',
                cls: 'team-member-save',
                disabled: true,
                scope: this,
                handler: this.saveForm
            });
        }

        return this.saveBtn;
    },

    saveForm : function()
    {
        this.getSaveButton().disable();

        var values = this.getValues(false, false, false, true),
            perTeamValues = {},
            inserts = [], updates = [], deletes = [];
        for (var i = 0; i < this.teamCount * this.MAX_TEAM_MEMBERS; i++)
        {
            var previousRowId = this.comboNameToRowIdMap['team-assignment-' + i],
                assignedUserId = values['team-assignment-' + i],
                assignedNofity = values['team-notify-' + i],
                teamNumber = Math.floor(i / 2) + 1;

            // keep track of input values per team for validation
            if (!perTeamValues[teamNumber])
                perTeamValues[teamNumber] = {assigned: [], notify: []};
            perTeamValues[teamNumber].assigned.push(assignedUserId);
            perTeamValues[teamNumber].notify.push(assignedNofity);

            // if we have a previous RowId, it is an update or delete
            if (previousRowId != null)
            {
                if (assignedUserId == null)
                {
                    deletes.push({RowId: previousRowId});
                }
                else
                {
                    updates.push({
                        RowId: previousRowId,
                        AdjudicationUserId: assignedUserId,
                        Notify: assignedNofity
                    });
                }
            }
            // otherwise only insert if we have an assignedUserId
            else if (assignedUserId != null)
            {
                inserts.push({
                    TeamNumber: teamNumber,
                    AdjudicationUserId: assignedUserId,
                    Notify: assignedNofity
                });
            }
        }

        // validation before submit (warnings, not errors)
        var warningMsg = '', sep = '';
        Ext4.Object.each(perTeamValues, function(key, value)
        {
            // first, check that at least on user is assigned for each team
            if (Ext4.Array.filter(value.assigned, function(val){return Ext4.isNumber(val); }).length == 0)
            {
                warningMsg += sep + 'Team ' + key + ' does not have any adjudicators assigned.';
                sep = '<br/>';
            }
        });
        if (warningMsg.length > 0)
        {
            warningMsg += '<br/>Would you like to proceed anyway?';
            Ext4.Msg.confirm('Warning', warningMsg, function(btn)
            {
                if (btn == 'yes')
                    this.saveRows(inserts, updates, deletes);
                else
                    this.getSaveButton().enable();
            }, this);
        }
        else
        {
            this.saveRows(inserts, updates, deletes);
        }
    },

    saveRows : function(inserts, updates, deletes)
    {
        // Note: order should be deletes, then inserts, then updates so that server side validation works as expected
        var commands = [];
        if (deletes.length > 0)
        {
            commands.push({
                command: 'delete',
                schemaName: 'adjudication',
                queryName: 'AdjudicationTeamUser',
                rows: deletes
            });
        }
        if (inserts.length > 0)
        {
            commands.push({
                command: 'insert',
                schemaName: 'adjudication',
                queryName: 'AdjudicationTeamUser',
                rows: inserts
            });
        }
        if (updates.length > 0)
        {
            commands.push({
                command: 'update',
                schemaName: 'adjudication',
                queryName: 'AdjudicationTeamUser',
                rows: updates
            });
        }

        // save all insert/updates/delets as a single transaction
        LABKEY.Query.saveRows({
            commands: commands,
            success: function(response)
            {
                window.location = LABKEY.ActionURL.buildURL('project', 'begin', null, {pageId: 'Manage'});
            },
            failure: function(response)
            {
                this.showErrorMsg(response.exception);
                this.getSaveButton().enable();
            },
            scope: this
        });
    },

    showErrorMsg : function(msg)
    {
        Ext4.Msg.show({
            title: 'Error',
            msg: msg,
            buttons: Ext4.Msg.OK,
            icon: Ext4.Msg.ERROR
        });
    }
});