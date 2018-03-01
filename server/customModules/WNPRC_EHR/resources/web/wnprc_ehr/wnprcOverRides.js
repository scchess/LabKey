/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('WNPRC_EHR');

EHR.DatasetButtons.registerMoreActionsCustomizer(function(dataRegionName){
    var dataRegion = LABKEY.DataRegions[dataRegionName],
        headerEl = Ext4.get('dataregion_header_row_' + dataRegion.name),
        menu_customized = false;

    if (headerEl) {
        var btnEls = Ext4.DomQuery.select('.labkey-menu-button', headerEl.dom);
        Ext4.each(btnEls, function(btnEl) {
            if (btnEl.innerHTML.indexOf('More Actions') > -1) {
                var menu = Ext4.menu.MenuMgr.get(Ext4.get(btnEl).getAttribute('lk-menu-id'));
                if (menu) {
                    menu_customized = true;
                    var action = LABKEY.ActionURL.getAction();
                    if (dataRegion.schemaName.match(/^study$/i) && dataRegion.queryName.match(/^Demographics$/i)) {
                        if (EHR.Security.hasPermission('Scheduled', 'insert', {queryName: 'Weight', schemaName: 'study'})) {
                            WNPRC_EHR.DatasetButtons.addCreateTaskFromIdsBtn(dataRegion.name, menu, {queries: [{schemaName: 'study', queryName: 'Weight'}], formType: 'Weight'});
                        }
                    }

                    if (action.match(/^dataEntry$/i) && dataRegion.schemaName.match(/^study$/i) && dataRegion.queryName.match(/^ClinpathRuns$/i)) {
                        if (EHR.Security.hasPermission('Scheduled', 'insert', {queryName: 'Clinpath Runs', schemaName: 'study'})) {
                            WNPRC_EHR.DatasetButtons.addCreateTaskBtn(dataRegion.name, menu, {queries: [{schemaName: 'study', queryName: 'Clinpath Runs'}], formType: 'Clinpath'});
                            WNPRC_EHR.DatasetButtons.addChangeQCStateBtn(dataRegion.name, menu);
                        }
                    }

                    if (dataRegion.schemaName.match(/^study$/i) && dataRegion.queryName.match(/^ClinpathRuns$/i)) {
                        if (EHR.Security.hasPermission('Completed', 'update', {queryName: 'Clinpath Runs', schemaName: 'study'})) {
                            WNPRC_EHR.DatasetButtons.addMarkReviewedBtn(dataRegion.name, menu);
                        }
                    }

                    if (action.match(/^dataEntry$/i) && dataRegion.schemaName.match(/^study$/i) && dataRegion.queryName.match(/^Blood$/i)) {
                        if (EHR.Security.hasPermission('Scheduled', 'insert', {queryName: 'Blood Draws', schemaName: 'study'})) {
                            WNPRC_EHR.DatasetButtons.addCreateTaskBtn(dataRegion.name, menu, {queries: [{schemaName: 'study', queryName: 'Blood Draws'}], formType: 'Blood Draws'});
                            WNPRC_EHR.DatasetButtons.addChangeBloodQCStateBtn(dataRegion.name, menu);
                        }
                    }

                    if (action.match(/^dataEntry$/i) && dataRegion.schemaName.match(/^study$/i) && dataRegion.queryName.match(/^StudyData$/i)) {
                        if (EHR.Security.hasPermission('Scheduled', 'insert', {queryName: 'Blood Draws', schemaName: 'study'})) {
                            WNPRC_EHR.DatasetButtons.addChangeQCStateBtn(dataRegion.name, menu);
                        }
                    }
                }
                return false;
            }
        });
    }
});


WNPRC_EHR.ProjectField2 = Ext.extend(LABKEY.ext.ComboBox, {
    initComponent: function() {
        Ext4.apply(this, {
            fieldLabel: 'Second Project',
            name: this.name || 'project_2',
            dataIndex: 'project_2',
            emptyText:'',
            displayField:'project',
            valueField: 'project',
            typeAhead: true,
            triggerAction: 'all',
            forceSelection: true,
            mode: 'local',
            disabled: false,
            plugins: ['ehr-usereditablecombo'],
            validationDelay: 500,
            //NOTE: unless i have this empty store an error is thrown
            store: new LABKEY.ext.Store({
                containerPath: 'WNPRC/EHR/',
                schemaName: 'study',
                requiredVersion: 9.1,
                sql: this.makeSql(),
                sort: 'project',
                autoLoad: true
            }),
            listeners: {
                select: function(combo, rec){
                    var target = this.findParentByType('ehr-formpanel');

                    if(target.boundRecord){
                        target.boundRecord.beginEdit();
                        target.boundRecord.set('project_2', rec.get('project'));
                        target.boundRecord.set('account_2', rec.get('account'));
                        target.boundRecord.endEdit();
                    }
                }
            },
            tpl: function(){
                var tpl = new Ext.XTemplate(
                    '<tpl for=".">' +
                    '<div class="x-combo-list-item">{[values["project"] + " " + (values["protocol"] ? "("+values["protocol"]+")" : "")]}' +
                    '&nbsp;</div></tpl>'
                );

                return tpl.compile()
            }()
        });

        WNPRC_EHR.ProjectField2.superclass.initComponent.call(this, arguments);

        var target = this.findParentByType('ehr-formpanel');
        console.log(target);

        this.mon(target, 'participantchange', this.getProjects2, this);
    },
    makeSql: function(id, date) {
        var sql = "SELECT DISTINCT a.project, a.project.account, a.project.protocol as protocol FROM study.assignment a " +
                "WHERE a.id='"+id+"' " +
                    //this protocol contains tracking projects
                "AND a.project.protocol != 'wprc00' ";

        if(!this.allowAllProtocols){
            sql += ' AND a.project.protocol IS NOT NULL '
        }

        if(date)
            sql += "AND cast(a.date as date) <= '"+date.format(LABKEY.extDefaultDateFormat)+"' AND (cast(a.enddate as date) >= '"+date.format(LABKEY.extDefaultDateFormat)+"' OR a.enddate IS NULL)";
        else
            sql += "AND a.enddate IS NULL ";

        if(this.defaultProjects){
            sql += " UNION ALL (SELECT project, account, project.protocol as protocol FROM ehr.project WHERE project IN ('"+this.defaultProjects.join("','")+"'))";
        }

        return sql;
    },
    getProjects2 : function(field, id) {
        console.log('get projects second iteration...');
        var target = this.findParentByType('ehr-formpanel');
        if(!id && target.boundRecord)
            id = target.boundRecord.get('Id');

        var date;
        if(target.boundRecord){
            date = target.boundRecord.get('date');
        }

        this.emptyText = 'Select second project...';
        this.store.baseParams.sql = this.makeSql(id, date);
        this.store.load();
    }
});

Ext.reg('ehr-project_2', WNPRC_EHR.ProjectField2);

EHR.Metadata.Columns['Irregular Observations'] = 'id/curlocation/location,id,id/curlocation/cond,date,enddate,inRoom,feces,menses,other,tlocation,behavior,otherbehavior,other,breeding,'+EHR.Metadata.bottomCols;
EHR.Metadata.Columns['Treatment Orders']       = EHR.Metadata.topCols+',account,meaning,code,qualifier,route,frequency,concentration,conc_units,dosage,dosage_units,volume,vol_units,amount,amount_units,remark,nocharge,project_2,account_2,billedby,performedBy,qcstate,'+EHR.Metadata.hiddenCols;
EHR.Metadata.Columns['Behavior Remarks']       = EHR.Metadata.topCols+',so,a,p,,behatype,category, behatreatment, followup,'+EHR.Metadata.bottomCols,
EHR.Metadata.Columns['Behavior Abstract']      = EHR.Metadata.topCols+',behavior,performedby,'+EHR.Metadata.bottomCols,
EHR.Metadata.Columns['Virology Results']       = EHR.Metadata.topCols+',virus,method,source,resultOORIndicator,result,units,qualResult,laboratory,'+EHR.Metadata.bottomCols,


EHR.Metadata.registerMetadata('Default', {
    byQuery: {
        cage_observations: {
            cage: {
                allowBlank: false
            }
        },
        'Blood Draws': {
            'id/curlocation/location': {
                shownInGrid: false
            },
            quantity: {
                shownInGrid: true
            },
            billedby: {
                shownInGrid: true
            },
            restraint: {
                shownInGrid: true,
                allowBlank: false
            },
            restraintDuration: {
                shownInGrid: true,
                allowBlank: false
            },
            project: {
                shownInGrid: false
            },
            tube_type: {
                shownInGrid: true // SPI (Jen) wants tube type to be there for folks doing th blood draws.
            },
            tube_vol: {
                shownInGrid: false
            },
            num_tubes: {
                shownInGrid: false
            },
            additionalServices: {
                shownInGrid: false
            },
            performedby: {
                shownInGrid: true
            }
        },
        'Chemistry Results': {
            date: { setInitialValue: function() { return null; } }
        },
        'Hematology Results': {
            date: { setInitialValue: function() { return null; } }
        },
        'Hematology Morphology': {
            date: { setInitialValue: function() { return null; } }
        },
        'Housing': {
            // Out Date
            enddate: {
                shownInGrid: false
            },
            cond: {
                shownInGrid: true
            },
            reason: {
                shownInGrid: true
            },
            performedby: {
                shownInGrid: true
            }
        },
        'Treatment Orders': {
            enddate: {
                setInitialValue: function(v,rec) {
                    return v ? v : new Date()
                }
            }
        },
        'Pregnancy':{
            conception:{
                editorConfig: {
                    listeners: {
                        change: function(field, val){
                            var theForm = this.ownerCt.getForm();
                            if(theForm){
                                conceptionDate = new Date (val);
                                conp40field = theForm.findField('conp40');
                                conceptionDate.setDate(conceptionDate.getDate()+40);
                                conp40field.setValue(conceptionDate);
                            }
                        }
                    }
                }
            }
        },
        Necropsies: {
            Weight: {
                date: {
                    parentConfig: {
                        storeIdentifier: {queryName: 'Necropsies', schemaName: 'study'}
                    },
                    hidden: false,
                    shownInGrid: false
                }
            }
        }
    }
});

EHR.Metadata.registerMetadata('Treatments', {
    allQueries: {
        project_2: {
            xtype: 'ehr-project_2',
            editorConfig: {
                defaultProjects: [300901]
            },
            shownInGrid: false,
            useNull: true,
            lookup: {
                columns: 'project,account'
            }
        },
        account_2: {
            shownInGrid: false
        }
    },
    byQuery: {
        'Treatment Orders': {
            project_2: {
                allowBlank: true
            },
            nocharge:{
                allowBlank: false
            }
        }
    }
});

/*
 * The following surgery changes are described in Issue 4340.
 */
EHR.Metadata.registerMetadata('Surgery', {
    byQuery: {
        "Drug Administration": {
            'id/curlocation/location': {
                shownInGrid: false
            },
            code: {
                colModel: {
                    width: 345,
                    fixed: true
                }
            },
            category: {
                shownInGrid: false
            },
            route: {
                shownInGrid: true,
                colModel: {
                    width: 110,
                    fixed: true
                }
            },
            amount: {
                shownInGrid: true,
                colModel: {
                    width: 70,
                    fixed: true
                }
            },
            amount_units: {
                shownInGrid: true,
                colModel: {
                    width: 95,
                    fixed: true
                }
            },
            volume: {
                shownInGrid: false
            },
            vol_units: {
                shownInGrid: false
            }
        }
    }
});

EHR.Metadata.registerMetadata('Irregular_Obs_OKRooms', {
    byQuery: {
        cage_observations: {
            no_observations: {
                shownInGrid: true,
                hidden: true,
                defaultValue: true
            },
            cage: {
                hidden: true,
                allowBlank: true,
                shownInGrid: false
            },
            feces: {
                hidden: true,
                shownInGrid: false
            },
            userid: {
                hidden: true
            }
        }
    }
});
EHR.Metadata.registerMetadata('MPR', {
    byQuery: {
        "Drug Administration": {
            'id/curlocation/location': {
                shownInGrid: false
            },
            route: {
                shownInGrid: true,
                colModel: {
                    width: 110,
                    fixed: true
                }
            },
            project: {
                shownInGrid: true,
                colModel: {
                    fixed: true,
                    width: 75
                }
            },
            code: {
                colModel: {
                    fixed: true,
                    width: 190
                }
            },
            category: {
                shownInGrid: false
            },
            volume: {
                shownInGrid: false
            },
            vol_units: {
                shownInGrid: false
            },
            performedby: {
                shownInGrid: true,
                colModel: {
                    width: 90,
                    fixed: true
                }
            },
            amount: {
                shownInGrid: true,
                colModel: {
                    width: 70,
                    fixed: true
                }
            },
            amount_units: {
                shownInGrid: true,
                colModel: {
                    width: 95,
                    fixed: true
                }
            }
        }
    }
});

/*
 * WNPRC#4350 - Make restraints not required for blood draw
 * requests (they should only be required for data entry).
 */
EHR.Metadata.registerMetadata('Request', {
    byQuery: {
        'Blood Draws': {
            restraint: {
                shownInGrid: false,
                allowBlank: true
            },
            restraintDuration: {
                shownInGrid: false,
                allowBlank: true
            }
        }
    }
});

Ext4.override(EHR.form.field.ProjectEntryField, {
    getDisallowedProtocols: function(){
        return ['wprc00'];
    }
});