/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('LABKEY.adj.ManageSettings', {

    extend: 'Ext.panel.Panel',

    border: false,

    // default values for manage settings (should match AdjudicationManager.getManageSettingsProperties)
    prefixType: 'folderName',
    prefixText: null,
    adjudicatorTeamCount: 2,
    requiredDetermination: 'hiv1Only',
    canUpdateSettings: false,

    PREFIX_FOLDER_NAME: 'Parent Folder Name',
    PREFIX_STUDY_NAME: 'Parent Study Name',
    PREFIX_TEXT: 'Text',
    DETERM_BOTH: 'Both HIV-1 and HIV-2',
    DETERM_HIV1: 'HIV-1 only',
    DETERM_HIV2: 'HIV-2 only',

    initComponent : function()
    {
        if (this.canUpdateSettings)
        {
            this.items = [this.getManageSettingsForm()];
        }
        else
        {
            this.items = [this.getManageSettingsDisplayView()];
        }

        this.callParent();

        window.onbeforeunload = LABKEY.beforeunload(this.isFormDirty, this);
    },

    getManageSettingsDisplayView : function()
    {
        if (!this.manageSettingsView)
        {
            this.manageSettingsView = Ext4.create('Ext.view.View', {
                tpl: new Ext4.XTemplate(
                    '<tpl if="filename != undefined">',
                        '<div class="manage-settings-note">Note: settings can not be changed once an adjudication case has been created in this folder.</div>',
                        '<div><span class="manage-settings-label">Required Filename Prefix:</span> {filename}</div>',
                        '<div><span class="manage-settings-label">Number of Adjudicator Teams:</span> {teamCount}</div>',
                        '<div><span class="manage-settings-label">Adjudication Determination Requires:</span> {determination}</div>',
                    '</tpl>'
                ),
                data: {
                    filename: this.prefixType == 'studyName' ? this.PREFIX_STUDY_NAME
                            : (this.prefixType == 'text' ? this.PREFIX_TEXT + ' (' + this.prefixText + ')'
                            : this.PREFIX_FOLDER_NAME),
                    teamCount: this.adjudicatorTeamCount,
                    determination: this.requiredDetermination == 'both' ? this.DETERM_BOTH
                            : (this.requiredDetermination == 'hiv2Only' ? this.DETERM_HIV2
                            : this.DETERM_HIV1)
                }
            });
        }

        return this.manageSettingsView;
    },

    getManageSettingsForm : function()
    {
        if (!this.manageSettingsForm)
        {
            this.manageSettingsForm = Ext4.create('Ext.form.Panel', {
                width: 500,
                height: 230,
                border: false,
                bodyPadding: 10,
                cls: 'manage-settings-form',
                items: [
                    this.getFilenamePrefixRadio(),
                    this.getAdjudicatorTeamCountNumberField(),
                    this.getRequiredDeterminationRadio(),
                    this.getSaveButton()
                ]
            });

            this.manageSettingsForm.on('dirtychange', function(form, dirty)
            {
                this.getSaveButton().setDisabled(!dirty);
            }, this);
        }

        return this.manageSettingsForm;
    },

    isFormDirty : function()
    {
        return !this.saveSuccess && this.getManageSettingsForm().isDirty();
    },

    getFilenamePrefixRadio : function()
    {
        if (!this.filenamePrefixRadio)
        {
            this.filenamePrefixRadio = Ext4.create('Ext.form.RadioGroup', {
                columns: 1,
                width: 480,
                fieldLabel: 'Required Filename Prefix',
                labelWidth: 250,
                items: [
                    {
                        boxLabel: this.PREFIX_FOLDER_NAME,
                        name: 'prefixType',
                        inputValue: 'folderName',
                        checked: this.prefixType == 'folderName'
                    },
                    {
                        boxLabel: this.PREFIX_STUDY_NAME,
                        name: 'prefixType',
                        inputValue: 'studyName',
                        checked: this.prefixType == 'studyName'
                    },
                    {
                        xtype: 'fieldcontainer',
                        layout: 'hbox',
                        hideLabel: true,
                        width: 300,
                        items: [
                            {
                                xtype: 'radio',
                                boxLabel: this.PREFIX_TEXT,
                                name: 'prefixType',
                                width: 55,
                                inputValue: 'text',
                                checked: this.prefixType == 'text'
                            },
                            this.getFilenamePrefixTextField()
                        ]
                    }
                ]
            });

            this.filenamePrefixRadio.on('change', function (radiogroup, newValue, oldValue)
            {
                // clear text field if the prefixType is no longer 'text'
                var isTextPrefixType = newValue.prefixType == 'text';
                if (!isTextPrefixType)
                {
                    this.getFilenamePrefixTextField().suspendEvents(false);
                    this.getFilenamePrefixTextField().setValue(null);
                    this.getFilenamePrefixTextField().resumeEvents();
                }
                this.getFilenamePrefixTextField().setDisabled(!isTextPrefixType);
            }, this);
        }

        return this.filenamePrefixRadio;
    },

    getFilenamePrefixTextField : function()
    {
        if (!this.filenamePrefixText)
        {
            this.filenamePrefixText = Ext4.create('Ext.form.field.Text', {
                name: 'prefixText',
                hideLabel: true,
                disabled: this.prefixType != 'text',
                value: this.prefixText
            });
        }

        return this.filenamePrefixText;
    },

    getAdjudicatorTeamCountNumberField : function()
    {
        if (!this.adjTeamCountNumberField)
        {
            this.adjTeamCountNumberField = Ext4.create('Ext.form.ComboBox', {
                name: 'adjudicatorTeamCount',
                cls: 'adj-combo',
                fieldLabel: 'Number of Adjudicator Teams',
                labelWidth: 250,
                width: 290,
                store: Ext4.create('Ext.data.Store', {
                    fields: ['value'],
                    data : [{value: 1}, {value: 2}, {value: 3}, {value: 4}, {value: 5}]
                }),
                editable: false,
                queryMode: 'local',
                displayField: 'value',
                valueField: 'value',
                value: this.adjudicatorTeamCount
            });

            this.adjTeamCountNumberField.on('change', this.saveProperties, this, {buffer: 500});
        }

        return this.adjTeamCountNumberField;
    },

    getRequiredDeterminationRadio : function()
    {
        if (!this.requiredDeterminationRadio)
        {
            this.requiredDeterminationRadio = Ext4.create('Ext.form.RadioGroup', {
                columns: 1,
                width: 400,
                fieldLabel: 'Adjudication Determination Requires',
                labelWidth: 250,
                items: [
                    {
                        boxLabel: this.DETERM_BOTH,
                        name: 'requiredDetermination',
                        width: 160,
                        inputValue: 'both',
                        checked: this.requiredDetermination == 'both'
                    },
                    {
                        boxLabel: this.DETERM_HIV1,
                        name: 'requiredDetermination',
                        inputValue: 'hiv1Only',
                        checked: this.requiredDetermination == 'hiv1Only'
                    },
                    {
                        boxLabel: this.DETERM_HIV2,
                        name: 'requiredDetermination',
                        inputValue: 'hiv2Only',
                        checked: this.requiredDetermination == 'hiv2Only'
                    }
                ]
            });
        }

        return this.requiredDeterminationRadio;
    },

    getSaveButton : function()
    {
        if (!this.saveButton)
        {
            this.saveButton = Ext4.create('Ext.button.Button', {
                text: 'Save',
                cls: 'admin-settings-save',
                disabled: true,
                handler: this.saveProperties,
                scope: this
            });
        }

        return this.saveButton;
    },

    saveProperties : function()
    {
        var form = this.getManageSettingsForm(),
            isValid = form.getForm().isValid(),
            values = form.getValues();

        if (!isValid)
        {
            return;
        }

        // clean up misc values
        if (!Ext4.isDefined(values.prefixText))
        {
            values.prefixText = null;
        }

        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'setManageSettings'),
            method: 'POST',
            jsonData: values,
            scope: this,
            success: function(response) {
                this.saveSuccess = true;
                window.location.reload();
            },
            failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options)
            {
                Ext4.Msg.show({
                    title: "Failure",
                    msg: "Error: " + (json ? json.exception : response.statusText),
                    buttons: Ext4.Msg.OK,
                    icon: Ext4.Msg.ERROR
                });
            })
        });
    }
});