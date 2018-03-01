/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * This field is used to display EHR projects.  It contains a custom template for the combo list which displays both the project and protocol.
 * It also listens for participantchange events and will display only the set of allowable projects for the selected animal.
 *
 * @cfg includeDefaultProjects defaults to true
 */
Ext4.define('EHR.form.field.ProjectCodeEntryField', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.ehr-projectcodeentryfield',

    fieldLabel: 'Project',
    typeAhead: true,
    forceSelection: true, //NOTE: has been re-enabled, but it is important to let the field get set prior to loading
    emptyText:'',
    disabled: false,
    matchFieldWidth: false,
    includeDefaultProjects: true,
    schemaName:'cnprc_ehr',

    initComponent: function(){
        this.allProjectStore = EHR.DataEntryUtils.getProjectCodeStore();

        this.trigger2Cls = Ext4.form.field.ComboBox.prototype.triggerCls;
        this.onTrigger2Click = Ext4.form.field.ComboBox.prototype.onTriggerClick;

        Ext4.apply(this, {
            // displayField: 'projectCode',
            valueField: 'projectCode',
            queryMode: 'local',
            plugins: [Ext4.create('LDK.plugin.UserEditableCombo', {
                createWindow: function(){
                    this.window = Ext4.create('Ext.window.Window', {
                        modal: true,
                        closeAction: 'destroy',
                        bodyStyle: 'padding: 5px',
                        title: 'Choose Project',
                        items: [{
                            xtype: 'ehr-projectCodefield',
                            width: 400,
                            fieldLabel: 'Project',
                            itemId: 'projectCodeField',
                            listeners: {
                                specialkey: function(field, e){
                                    if (e.getKey() === e.ENTER && !field.isExpanded){
                                        var btn = field.up('window').down('button[text=Submit]');
                                        btn.handler.apply(btn.scope, [btn]);
                                    }
                                }
                            }
                        },{
                            xtype: 'ldk-linkbutton',
                            linkTarget: '_blank',
                            text: '[View All Projects]',
                            href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'cnprc_ehr', 'query.queryName': 'project', 'query.viewName': 'Active Projects'}),
                            style: 'padding-top: 5px;padding-bottom: 5px;padding-left: 100px;'
                        }],
                        buttons: [{
                            scope: this,
                            text: 'Submit',
                            handler: function(btn){
                                var win = btn.up('window');
                                var field = win.down('#projectCodeField');
                                var projectCode = field.getValue();
                                if (!projectCode){
                                    Ext4.Msg.alert('Error', 'Must enter a project');
                                    return;
                                }

                                var rec = field.findRecord('projectCode', projectCode);
                                LDK.Assert.assertTrue('Project record not found for id: ' + projectCode, !!rec);

                                if (rec){
                                    this.onPrompt('ok', {
                                        projectCode: projectCode,
                                        title: rec.get('title'),
                                        investigator: rec.get('investigatorId/lastName')
                                    });

                                    win.close();
                                }
                                else {
                                    Ext4.Msg.alert('Error', 'Unknown Project');
                                }
                            }
                        },{
                            text: 'Cancel',
                            handler: function(btn){
                                btn.up('window').close();
                            }
                        }],
                        listeners: {
                            show: function(win){
                                var field = win.down('combo');
                                Ext4.defer(field.focus, 100, field);
                            }
                        }
                    }).show();
                },

                onBeforeComplete: function(){
                    return !this.window || !this.window.isVisible();
                }
            })],
            validationDelay: 500,
            //NOTE: unless i have this empty store an error is thrown
            store: {
                type: 'labkey-store',
                schemaName: 'study',
                sql: this.makeSql(),
                sort: 'sort_order,projectCode',
                autoLoad: false,
                loading: true,
                listeners: {
                    scope: this,
                    delay: 50,
                    load: function(store){
                        this.resolveProjectFromStore();
                        this.getPicker().refresh();
                    }
                }
            },
            listeners: {
                scope: this,
                beforerender: function(field){
                    var target = field.up('form');
                    if (!target)
                        target = field.up('grid');

                    LDK.Assert.assertNotEmpty('Unable to find form or grid', target);
                    if (target) {
                        field.mon(target, 'animalchange', field.getProjects, field);
                    }
                    else {
                        console.error('Unable to find target');
                    }

                    //attempt to load for the bound Id
                    this.getProjects();
                }
            }
        });

        this.listConfig = this.listConfig || {};
        Ext4.apply(this.listConfig, {
            innerTpl: this.getInnerTpl(),
            getInnerTpl: function(){
                return this.innerTpl;

            },
            style: 'border-top-width: 1px;' //this was added in order to restore the border above the boundList if it is wider than the field
        });

        this.callParent(arguments);

        this.on('render', function(){
            Ext4.QuickTips.register({
                target: this.triggerEl.elements[0],
                text: 'Click to recalculate allowable projects'
            });
        }, this);
    },

    getInnerTpl: function(){
        return ['<span style="white-space:nowrap;{' +
        '[values["isAssigned"] ? "font-weight:bold;" : ""]}">{[' +
        ' values["projectCode"]' +
        ' + " " + (values["title"] ? ("(" + values["title"] + ")") : "")' +
        ']}&nbsp;</span>'];
    },

    trigger1Cls: 'x4-form-search-trigger',

    onTrigger1Click: function(){
        var boundRecord = EHR.DataEntryUtils.getBoundRecord(this);
        if (!boundRecord){
            Ext4.Msg.alert('Error', 'Unable to locate associated animal Id');
            return;
        }

        var id = boundRecord.get('Id');
        if (!id){
            Ext4.Msg.alert('Error', 'No Animal Id Provided');
            return;
        }

        this.getProjects(id);
    },

    getDisallowedProtocols: function(){
        return null;
    },

    makeSql: function(id, date){
        if (!id && !this.includeDefaultProjects)
            return;

        //avoid unnecessary reloading
        var key = id + '||' + date;
        if (this.loadedKey == key){
            return;
        }
        this.loadedKey = key;

        var sql = "SELECT DISTINCT t.projectCode, t.investigator, t.title,  " +
                "false as fromClient, min(sort_order) as sort_order, max(isAssigned) as isAssigned FROM (";

        if (id){
            //NOTE: show any actively assigned projects, or projects under the same protocol.  we also only show projects if either the animal is assigned, or that project is active
            sql += "SELECT p.projectCode as projectCode, " +
                    "p.title,  " +
                    "p.oi_name as investigator, " +
                    "1 as sort_order, " +
                    "CASE WHEN (a.projectCode = p.projectCode) THEN 1 ELSE 0 END as isAssigned " +
                    " FROM cnprc_ehr.project p JOIN study.assignment a ON (a.projectCode = p.projectCode) " +
                    " WHERE a.id='"+id+"' AND (a.projectCode = p.projectCode) "; //TODO: restore this OR p.enddate IS NULL OR p.enddate >= curdate()

            //NOTE: if the date is in the future, we assume active projects
            if (date){
                sql += "AND cast(a.date as date) <= '"+date.format('Y-m-d')+"' AND ((a.enddateCoalesced >= '"+date.format('Y-m-d')+"') OR ('"+date.format('Y-m-d')+"' >= now() and a.enddate IS NULL))";
            }
            else {
                sql += "AND a.isActive = true ";
            }

            if (this.getDisallowedProtocols()){
                sql += " AND p.protocol NOT IN ('" + this.getDisallowedProtocols().join("', '") + "') ";
            }
        }

        if (this.includeDefaultProjects){
            if (id)
                sql += ' UNION ALL ';

            sql += " SELECT p.projectCode," +
                    "p.oi_name as investigator," +
                    "p.title, " +
                    "3 as sort_order, " +
                    "0 as isAssigned " +
                    "FROM cnprc_ehr.project p ";
            // "WHERE p.alwaysavailable = true"; //TODO: restore this: and p.enddateCoalesced >= curdate()
        }

        sql+= " ) t GROUP BY t.projectCode,t.investigator, t.title";

        return sql;
    },

    getProjects : function(id){
        var boundRecord = EHR.DataEntryUtils.getBoundRecord(this);
        if (!boundRecord){
            console.warn('no bound record found');
        }

        if (boundRecord && boundRecord.store){
            LDK.Assert.assertNotEmpty('ProjectEntryField is being used on a store that lacks an Id field: ' + boundRecord.store.storeId, boundRecord.fields.get('Id'));
        }

        if (!id && boundRecord)
            id = boundRecord.get('Id');

        var date;
        if (boundRecord){
            date = boundRecord.get('date');
        }

        this.emptyText = 'Select project...';
        var sql = this.makeSql(id, date);
        if (sql){
            this.store.loading = true;
            this.store.sql = sql;
            this.store.removeAll();
            this.store.load();
        }
    },

    setValue: function(val){
        var rec;
        if (Ext4.isArray(val)){
            val = val[0];
        }

        // if (val){
        if (val && Ext4.isPrimitive(val)){
            rec = this.store.findRecord('projectCode', val);
            if (!rec){
                rec = this.store.findRecord('projectCode', val, null, false, false, true);

                if (rec)
                    console.log('resolved project entry field by display value')
            }

            if (!rec){
                rec = this.resolveProject(val);
            }
        }

        if (rec){
            val = rec;
        }

        // NOTE: if the store is loading, Combo will set this.value to be the actual model.
        // this causes problems downstream when other code tries to convert that into the raw datatype
        if (val && val.isModel){
            val = val.get(this.valueField);
        }

        this.callParent([val]);
    },

    resolveProjectFromStore: function(){
        var val = this.getValue();
        if (!val || this.isDestroyed)
            return;

        LDK.Assert.assertNotEmpty('Unable to find store in ProjectEntryField', this.store);
        var rec = this.store ? this.store.findRecord('projectCode', val) : null;
        if (rec){
            return;
        }

        rec = this.allProjectStore.findRecord('projectCode', val);
        if (rec){
            var newRec = this.store.createModel({});
            newRec.set({
                projectCode: rec.data.projectCode,
                account: rec.data.account,
                title: rec.data.title,
                investigator: rec.data['investigatorId/lastName'],
                isAssigned: 0,
                fromClient: true
            });

            this.store.insert(0, newRec);

            return newRec;
        }
    },

    resolveProject: function(val){
        if (this.allProjectStore.isLoading()){
            this.allProjectStore.on('load', function(store){
                var newRec = this.resolveProjectFromStore();
                if (newRec)
                    this.setValue(val);
            }, this, {single: true});
        }
        else {
            this.resolveProjectFromStore();
        }
    }
});