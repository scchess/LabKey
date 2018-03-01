/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Survey widget to group a series of combos in a field container
 */
LABKEY.mpower = LABKEY.mpower || {};

LABKEY.mpower.stores = {
    STANDARD : 'mpower_standard_scale_store',
    PROBLEM  : 'mpower_problem_scale_store',
    DIAGNOSIS_AGE  : 'mpower_diagnosis_age_store',
    CANCER_LOCATION : 'mpower_cancer_location_store',
    DIAGNOSIS_STATUS: 'mpower_diagnosis_status_store',
    SATISFACTION: 'mpower_satisfaction_store',
    URINE_LEAK  : 'mpower_urine_leak_store',
    URINE_CONTROL : 'mpower_urine_control_store',
    DIAPER_USE    : 'mpower_diaper_use_store',
    ERECTION_QUALITY : 'mpower_erection_quality_store',
    ERECTION_FREQUENCY : 'mpower_erection_frequency_store',
    DAYS_OF_EXERCISE : 'mpower_days_of_exercise_store',
    ATTEND_SUPPORT_GROUP : 'mpower_attend_support_group_store',
    YES_NO_OTHER : 'mpower_yes_no_other_store',
    YES_NO : 'mpower_yes_no_store',
    COMMERCIAL_INSURANCE : 'mpower_commercial_insurance',
    MILITARY_INSURANCE : 'mpower_military_insurance',
    SURGERY_TYPE : 'mpower_surgery_type'
};

LABKEY.mpower.Util = new function() {

    return {
        initStores : function() {

            // model used by multiple stores
            Ext4.define('LABKEY.data.mpower.Lookup', {
                extend : 'Ext.data.Model',
                fields : [
                    {name : 'Id'},
                    {name : 'Name'}
                ]
            });

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.PROBLEM)) {

                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.PROBLEM,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'problemScale',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.STANDARD)) {

                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 10000,
                    storeId : LABKEY.mpower.stores.STANDARD,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'standardScale',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.DIAGNOSIS_AGE)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.DIAGNOSIS_AGE,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'ageAtDiagnosis',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.CANCER_LOCATION)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.CANCER_LOCATION,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'cancerStartLocation',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.DIAGNOSIS_STATUS)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.DIAGNOSIS_STATUS,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'diagnosisStatus',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.SATISFACTION)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.SATISFACTION,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'treatmentSatisfaction',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.URINE_LEAK)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.URINE_LEAK,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'urineLeak',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.URINE_CONTROL)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.URINE_CONTROL,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'urineControl',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.DIAPER_USE)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.DIAPER_USE,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'diaperUse',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.ERECTION_QUALITY)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.ERECTION_QUALITY,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'erectionQuality',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.ERECTION_FREQUENCY)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.ERECTION_FREQUENCY,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'erectionFrequency',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.DAYS_OF_EXERCISE)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.DAYS_OF_EXERCISE,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'daysOfExercise',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.ATTEND_SUPPORT_GROUP)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.ATTEND_SUPPORT_GROUP,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'attendSupportGroup',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.YES_NO_OTHER)) {
                Ext4.create('Ext.data.Store', {
                    model   : 'LABKEY.data.mpower.Lookup',
                    autoLoad: true,
                    pageSize: 100,
                    storeId : LABKEY.mpower.stores.YES_NO_OTHER,
                    proxy : {
                        type : 'ajax',
                        url    : LABKEY.ActionURL.buildURL('query', 'selectRows.api'),
                        extraParams : {
                            schemaName  : 'mpower',
                            queryName   : 'yesNoOther',
                            sort        : 'name'
                        },
                        reader : { type : 'json', root : 'rows' }
                    }
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.YES_NO)) {
                Ext4.create('Ext.data.Store', {
                    storeId : LABKEY.mpower.stores.YES_NO,
                    fields  : ["value", "name"],
                    data : [
                        {"name": "Yes", "value" : true},
                        {"name": "No", "value" : false}
                    ]
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.COMMERCIAL_INSURANCE)) {
                Ext4.create('Ext.data.Store', {
                    storeId : LABKEY.mpower.stores.COMMERCIAL_INSURANCE,
                    fields  : ["value"],
                    data    : [
                        {"value": "BridgeSpan Health Company"},
                        {"value": "Columbia United Providers"},
                        {"value": "Community Health Plan of Washington"},
                        {"value": "Coordinated Care"},
                        {"value": "Group Health Cooperative"},
                        {"value": "Kaiser Foundation Health Plan of the Northwest"},
                        {"value": "LifeWise Health Plan of Washington"},
                        {"value": "Molina Healthcare of Washington"},
                        {"value": "Premera Blue Cross"},
                        {"value": "Public Employees Benefit Plan"},
                        {"value": "Regence Health Insurance"}
                    ]
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.MILITARY_INSURANCE)) {
                Ext4.create('Ext.data.Store', {
                    storeId : LABKEY.mpower.stores.MILITARY_INSURANCE,
                    fields  : ["value"],
                    data    : [
                        {"value": "Veteran's Administration (VA) Health Care"},
                        {"value": "Military Healthcare (including CHAMPUS/TriCARE, CHAMP-VA"}
                    ]
                });
            }

            if (!Ext4.data.StoreManager.lookup(LABKEY.mpower.stores.SURGERY_TYPE)) {
                Ext4.create('Ext.data.Store', {
                    storeId : LABKEY.mpower.stores.SURGERY_TYPE,
                    fields  : ["value", "label"],
                    data    : [
                        {
                            "value": "Minimally invasive technique",
                            "label": "Minimally invasive technique using robotic surgery"
                        },{
                            "value": "Open technique",
                            "label": "Open technique (Surgery incision is often 4-5 inches long)"
                        },{
                            "value": "Do not know",
                            "label": "Do not know the type of operation"
                        }
                    ]
                });
            }
        }
    }
};

Ext4.define('LABKEY.ext4.form.field.ComboContainer', {
    extend: 'Ext.form.FieldContainer',
    alias: 'widget.mpower_combocontainer',

    constructor: function (config)
    {
        Ext4.applyIf(config, {
            layout  : "vbox",
            width   : 800,
            defaults    : {
                xtype       : "combo",
                labelWidth  : 200,
                displayField: "Name",
                valueField  : "Id",
                emptyText   : "Select",
                editable    : false,
                forceSelection  : false,
                store       : LABKEY.mpower.stores.PROBLEM
            }
        });
        this.callParent([config]);
    },

    initComponent: function ()
    {
        this.callParent();
    }
});

Ext4.define('LABKEY.ext4.form.field.CheckContainer', {
    extend: 'Ext.form.FieldContainer',
    alias: 'widget.mpower_checkcontainer',

    constructor: function (config)
    {
        Ext4.applyIf(config, {
            defaults    : {
                xtype       : "checkbox",
                labelWidth  : 310,
                displayField: "Name",
                valueField  : "Id",
                emptyText   : "Select",
                editable    : false,
                forceSelection  : false,
                labelStyle  : "padding-left: 17px;",
                store       : LABKEY.mpower.stores.DIAGNOSIS_AGE
            }
        });
        this.callParent([config]);
    },

    initComponent: function ()
    {
        this.callParent();
    }
});

Ext4.define('LABKEY.ext4.form.field.CancerInfo', {
    extend: 'Ext.form.FieldContainer',
    alias: 'widget.mpower_cancerinfo',

    constructor: function (config)
    {
        Ext4.applyIf(config, {
            defaults    : {
                xtype       : 'combo',
                labelWidth  : 310,
                displayField: "Name",
                valueField  : "Id",
                editable    : false,
                emptyText   : "Select",
                labelStyle  : "padding-left: 17px;",
                store       : LABKEY.mpower.stores.CANCER_LOCATION
            }
        });
        this.callParent([config]);
    },

    initComponent: function ()
    {
        this.callParent();
    }
});

Ext4.define('LABKEY.ext4.form.field.FamilyMemberProstateButton', {
    extend: 'Ext.button.Split',
    alias: 'widget.mpower_familymember_prostatebtn',

    constructor: function (config)
    {
        Ext4.applyIf(config, {
            text    : 'Add Additional Family Members'
        });
        this.componentCount = 1;
        this.callParent([config]);
    },

    initComponent: function ()
    {
        this.menu = {
            xtype : 'menu',
            items : [
                {text : 'Brother (full, half)', handler : function(cmp){this.addRow(cmp, 'Brother (full, half)', 1);}, scope : this},
                {text : 'Children', handler : function(cmp){this.addRow(cmp, 'Children', 3);}, scope : this},
                {text : 'Cousins on mother\'s side', handler : function(cmp){this.addRow(cmp, 'Cousins on mother\'s side', 7);}, scope : this},
                {text : 'Cousins on father\'s side', handler : function(cmp){this.addRow(cmp, 'Cousins on father\'s side', 11);}, scope : this}
        ]

        };
        this.callParent();
    },

    addRow : function(cmp, label, inputValue){
        var parent = this.findParentByType('panel');
        if (parent){
            var targetCmp = parent.getComponent(this.targetCmp);
            if (targetCmp){
                targetCmp.add(this.getRowFields(label, inputValue));
            }
        }
    },

    getRowFields : function(label, inputValue) {

        return[{
            xtype       : "checkbox",
            boxLabel    : label,
            name        : 'relatives_with_prostate_cancer',
            inputValue  : inputValue,
            labelWidth  : 310
        },{
            xtype       : "combo",
            name        : 'relatives_with_prostate_cancer_age_diagnosis',
            displayField: "Name",
            valueField  : "Id",
            emptyText   : "Select",
            editable    : false,
            fieldLabel  : 'How old were they when they were diagnosed?',
            forceSelection  : false,
            labelStyle  : "padding-left: 17px;",
            store       : LABKEY.mpower.stores.DIAGNOSIS_AGE
        }];
    }
});

Ext4.define('LABKEY.ext4.form.field.FamilyMemberCancerButton', {
    extend: 'Ext.button.Split',
    alias: 'widget.mpower_familymember_cancerbtn',

    constructor: function (config)
    {
        Ext4.applyIf(config, {
            text    : 'Add Additional Family Members'
        });
        this.callParent([config]);
    },

    initComponent: function ()
    {
        this.menu = {
            xtype : 'menu',
            items : [
                {text : 'Sister (full, half)', handler : function(cmp){this.addRow(cmp, 'Sister (full, half)', 2);}, scope : this},
                {text : 'Brother (full, half)', handler : function(cmp){this.addRow(cmp, 'Brother (full, half)', 1);}, scope : this},
                {text : 'Children', handler : function(cmp){this.addRow(cmp, 'Children', 3);}, scope : this}
            ]

        };
        this.callParent();
    },

    addRow : function(cmp, label, inputValue){
        var parent = this.findParentByType('panel');
        if (parent){
            var targetCmp = parent.getComponent(this.targetCmp);
            if (targetCmp){
                targetCmp.add(this.getRowFields(label, inputValue));
            }
        }
    },

    getRowFields : function(label, inputValue) {

        return[{
            xtype       : "checkbox",
            boxLabel    : label,
            name        : 'relatives_with_other_cancer',
            inputValue  : inputValue,
            labelWidth  : 310
        },{
            xtype       : "mpower_cancerinfo",
            items: [
                {
                    fieldLabel  : "Where did the cancer start?",
                    name        : "relatives_with_other_cancer_startlocation"
                },{
                    fieldLabel  : "How old were they when they were diagnosed?",
                    name        : "relatives_with_other_cancer_age_diagnosis",
                    store       : LABKEY.mpower.stores.DIAGNOSIS_AGE
                }
            ]
        }];
    }
});