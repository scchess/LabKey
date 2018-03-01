/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains CNPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled

EHR.reports.CNPRCSnapshot = function(panel, tab, showActionsBtn){
    if (tab.filters.subjects){
        renderSubjects(tab.filters.subjects, tab);
    }
    else {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab){
        var toAdd = [];
        if (!subjects.length){
            toAdd.push({
                html: 'No animals were found.',
                border: false
            });
        }
        else if (subjects.length < 10) {
            for (var i=0;i<subjects.length;i++) {
                toAdd.push({
                    xtype: 'ldk-webpartpanel',
                    title: 'Overview: ' + subjects[i],
                    items: [{
                        xtype: 'cnprc_ehr-snapshotpanel',
                        showExtendedInformation: true,
                        showActionsButton: !!showActionsBtn,
                        hrefTarget: '_blank',
                        border: false,
                        subjectId: subjects[i]
                    }]
                });

                toAdd.push({
                    border: false,
                    height: 20
                });

                toAdd.push(EHR.reports.renderWeightData(panel, tab, subjects[i]));
            }
        }
        else {
            toAdd.push({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Show Hx\'.',
                style: 'padding-bottom: 20px;',
                border: false
            });

            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            toAdd.push({
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;',
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographics',
                    viewName: 'Snapshot',
                    filterArray: filterArray.removable.concat(filterArray.nonRemovable)
                }
            });
        }

        if (toAdd.length)
            tab.add(toAdd);
    }

};

EHR.reports.renderWeightData = function(panel, tab, subject){
    return {
        xtype: 'ldk-webpartpanel',
        title: 'Weights - ' + subject,
        style: 'margin-bottom: 20px;',
        border: false,
        items: [{
            xtype: 'cnprc_ehr-weightsummarypanel',
            style: 'padding-bottom: 20px;',
            subjectId: subject
        },{
            xtype: 'cnprc_ehr-weightgraphpanel',
            itemId: 'tabArea',
            showRawData: true,
            border: false,
            subjectId: subject
        }]
    }
};

EHR.reports.immunizations = function (panel, tab, viewName) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:10px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'drug',
            viewName: viewName,
            title: 'Immunizations' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });

    //legends for Immunization report
    tab.add({
        xtype: 'ldk-webpartpanel',
        title: 'Legend',
        items: [{
            border: false,
            html: '<table class="ehr-legend">' +
            CNPRC.Utils.legendEntry('DT', 'Diphtheria + Tetanus', true, true) +
            CNPRC.Utils.legendEntry('ET', 'Equine tetanus', true, true) +
            CNPRC.Utils.legendEntry('K', 'Canine distemper', true, true) +
            CNPRC.Utils.legendEntry('M', 'Rubeola vaccine', true, true) +
            CNPRC.Utils.legendEntry('MX', 'Measles experimental', true, true) +
            CNPRC.Utils.legendEntry('T', 'Tetanus', true, true) +
            CNPRC.Utils.legendEntry('~N', 'Natural infections', true, true) +
            CNPRC.Utils.legendEntry('~X', 'Experimental', true, true) +
            '</table>'
        }]
    });
};

EHR.reports.pairingHistory = function (panel, tab, viewName) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:10px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'pairingHistory',
            viewName: viewName,
            title: 'Pairing' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });

    //legends for Pairing History report
    tab.add({
        xtype: 'ldk-webpartpanel',
        title: 'Legend',
        items: [{
            border: false,
            html: '<table class="ehr-legend">' +
            CNPRC.Utils.legendTitle('Pairing Codes', true, false) +                           CNPRC.Utils.legendTitle('Deferment Status Codes', false, true) +
            CNPRC.Utils.legendEntry('CG', 'Continuous pair with grate', true, false) +        CNPRC.Utils.legendEntry('XS', 'Experimental deferral, single', false, true) +
            CNPRC.Utils.legendEntry('CP', 'Continuous pair', true, false) +                   CNPRC.Utils.legendEntry('XD', 'Experimental deferral, no group mate', false, true) +
            CNPRC.Utils.legendEntry('IG', 'Intermittent pair with grate', true, false) +      CNPRC.Utils.legendEntry('XG', 'Experimental deferral with grate', false, true) +
            CNPRC.Utils.legendEntry('IP', 'Intermittent pair', true, false) +                 CNPRC.Utils.legendEntry('PS', 'Permanent deferral, social incompatibility', false, true) +
            CNPRC.Utils.legendEntry('U', 'Unsuccessful', true, false) +                       CNPRC.Utils.legendEntry('AW', 'Single, awaiting pairing', false, true) +
            CNPRC.Utils.legendEntry('SP', 'Socialization play, play groups', true, false) +   CNPRC.Utils.legendEntry('CF', 'Compatible, then fought (Retired code)', false, true) +
            CNPRC.Utils.legendEntry('F', 'Fought (Retired code)', true, false) +              CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry('C', 'Compatible (Retired code)', true, false) +          CNPRC.Utils.legendEntry('', '', false, true) +
            '</table>'
        }]
    });
};

EHR.reports.virologyReport = function (panel, tab, viewName) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:10px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'virologyReport',
            viewName: viewName,
            title: 'Virology' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });

    //legends for Virology report
    tab.add({
        xtype: 'ldk-webpartpanel',
        title: 'Legend',
        items: [{
            border: false,
            html: '<table class="ehr-legend">' +
            CNPRC.Utils.legendTitle('Virus', true, false) +                                               CNPRC.Utils.legendTitle('Result', false, true) +
            CNPRC.Utils.legendEntry('CMV', 'Cytomegalovirus', true, false) +                              CNPRC.Utils.legendEntry('+', 'Positive', false, true) +
            CNPRC.Utils.legendEntry('HERB', 'Herpes B virus', true, false) +                              CNPRC.Utils.legendEntry('-', 'Negative', false, true) +
            CNPRC.Utils.legendEntry('SRV', 'Simian Retrovirus, no specific serotype', true, false) +      CNPRC.Utils.legendEntry('?', 'Indeterminate', false, true) +
            CNPRC.Utils.legendEntry('SRVx', 'Simian Retrovirus serotype, where x denotes serotypes', true, false) + CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry('SIV', 'Simian Immunodeficiency Virus, no specific origin', true, false) + CNPRC.Utils.legendTitle('Sample Type', false, true) +
            CNPRC.Utils.legendEntry('SIVMAC', 'SIV, macaque origin', true, false) +                       CNPRC.Utils.legendEntry('PBL', 'Peripheral blood lymphocytes', false, true) +
            CNPRC.Utils.legendEntry('SIVSMM', 'SIV, sooty mangabey origin', true, false) +                CNPRC.Utils.legendEntry('SAL', 'Saliva', false, true) +
            CNPRC.Utils.legendEntry('SIVAGM', 'SIV, African green monkey origin', true, false) +          CNPRC.Utils.legendEntry('SER', 'Serum', false, true) +
            CNPRC.Utils.legendEntry('STLV1', 'Simian T-cell leukemia virus, serotype 1', true, false) +   CNPRC.Utils.legendEntry('CSF', 'Cerebrospinal fluid', false, true) +
            CNPRC.Utils.legendEntry('HIV', 'Human Immunodeficiency Virus, serotype 1', true, false) +     CNPRC.Utils.legendEntry('EYE', 'Tissuefluid collected from either eye', false, true) +
            CNPRC.Utils.legendEntry('HIV2', 'Human Immunodeficiency Virus, serotype 2', true, false) +    CNPRC.Utils.legendEntry('GEN', 'Tissuefluid collected from genitalia', false, true) +
            CNPRC.Utils.legendEntry('FOAMY', 'Simian Foamy Virus (SFV)', true, false) +                   CNPRC.Utils.legendEntry('OTH', 'Other', false, true) +
            CNPRC.Utils.legendEntry('RRV', 'Rhesus Rhadinovirus', true, false) +                          CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry('', '', true, false) +                                                CNPRC.Utils.legendTitle('Test Method', false, true) +
            CNPRC.Utils.legendTitle('Target', true, false) +                                              CNPRC.Utils.legendEntry('EL', 'ELISA', false, true) +
            CNPRC.Utils.legendEntry('AB', 'Antibody', true, false) +                                      CNPRC.Utils.legendEntry('IF', 'Immunoflourescent assay', false, true) +
            CNPRC.Utils.legendEntry('AG', 'Antigen', true, false) +                                       CNPRC.Utils.legendEntry('MI', 'Multiplex microbead Immunoassay', false, true) +
            CNPRC.Utils.legendEntry('NA', 'Nucleic acid for PCR', true, false) +                          CNPRC.Utils.legendEntry('PC', 'PCR', false, true) +
            CNPRC.Utils.legendEntry('VI', 'Virus Isolation', true, false) +                               CNPRC.Utils.legendEntry('RJ', 'Raji cell assay', false, true) +
            CNPRC.Utils.legendEntry('', '', true, false) +                                                CNPRC.Utils.legendEntry('VC', 'Virus culture', false, true) +
            CNPRC.Utils.legendEntry('', '', true, false) +                                                CNPRC.Utils.legendEntry('WB', 'Western Blot', false, true) +
            '</table>'
        }]
    });
};

EHR.reports.weightTbBcs = function (panel, tab, viewName) {
    var filterArray = panel.getFilterArray(tab);
    var subjects = filterArray.subjects;
    var columnName = 'Id';

    if (filterArray.nonRemovable.length > 0)
        columnName = filterArray.nonRemovable[0].getColumnName();

    if ( Ext4.isDefined(subjects) && subjects.length < 11 ) {
        subjects.forEach(function(subj){
            tab.add({
                xtype: 'ldk-webpartpanel',
                title: 'Weight Overview: ' + subj,
                items: [{
                    xtype: 'cnprc_ehr-weightsummarypanel',
                    style: 'padding-bottom: 20px;',
                    subjectId: subj
                },{
                    xtype: 'cnprc_ehr-weightgraphpanel',
                    itemId: 'tabArea',
                    showRawData: false,
                    border: false,
                    subjectId: subj
                }]
            });

            tab.add({
                xtype: 'ldk-querycmp',
                style: 'margin-bottom:10px;',
                queryConfig: panel.getQWPConfig({
                    schemaName: 'study',
                    queryName: 'WeightsTbAndBodyCondition',
                    viewName: viewName,
                    title: 'Weight, TB and Body Condition: ' + subj,
                    filters: [LABKEY.Filter.create(columnName, subj)],
                    removeableFilters: filterArray.removable
                })
            });
        }, this);

    }
    else {
        tab.add({
            html: 'Because more than 10 subjects were selected, the condensed report is being shown.',
            style: 'padding-bottom: 20px;',
            border: false
        });
        tab.add({
            xtype: 'ldk-querycmp',
            style: 'margin-bottom:10px;',
            queryConfig: panel.getQWPConfig({
                schemaName: 'study',
                queryName: 'WeightsTbAndBodyCondition',
                viewName: viewName,
                title: 'Weights, TB and Body Condition',
                filters: filterArray.nonRemovable,
                removeableFilters: filterArray.removable
            })
        });
    }



};

EHR.reports.conceptionHistory = function (panel, tab, viewName) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:10px;',
        queryConfig: panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'pregnancyConfirmations',
            viewName: viewName,
            title: 'Conception History ' + title,
            filters: filterArray.nonRemovable,
            removeableFilters: filterArray.removable
        })
    });

    //legends for Conception History report
    tab.add({
        xtype: 'ldk-webpartpanel',
        title: 'Legend',
        items: [{
            border: false,
            html: '<table class="ehr-legend">' +
            CNPRC.Utils.legendTitle('Sex', true, false) +               CNPRC.Utils.legendTitle('Death Type', false, false) +                           CNPRC.Utils.legendTitle('Delivery Type', false, true) +
            CNPRC.Utils.legendEntry('F', 'Female', true, false) +       CNPRC.Utils.legendEntry('X', 'Experimental', false, false)+                     CNPRC.Utils.legendEntry('LV', 'Live Vaginal', false, true) +
            CNPRC.Utils.legendEntry('M', 'Male', true, false) +         CNPRC.Utils.legendEntry('K', 'Medical Cull', false, false)+                     CNPRC.Utils.legendEntry('LN', 'Live Non Vaginal', false, true) +
            CNPRC.Utils.legendEntry('U', 'Unknown', true, false) +      CNPRC.Utils.legendEntry('A' ,'Experimental Accident', false, false) +           CNPRC.Utils.legendEntry('LVX', 'Live Vaginal Experimental', false, true) +
            CNPRC.Utils.legendEntry('X', 'Hermaphrodite', true, false) +CNPRC.Utils.legendEntry('D' ,'Spontaneous Death', false, false) +             CNPRC.Utils.legendEntry('LNX', 'Live Non Vaginal Experimental', false, true) +
            CNPRC.Utils.legendEntry('', '', true, false) +              CNPRC.Utils.legendEntry('FD','Fetal Death', false, false) +                     CNPRC.Utils.legendEntry('DV', 'Dead Vaginal', false, true) +
            CNPRC.Utils.legendTitle('Est', true, false) +               CNPRC.Utils.legendEntry('FL','Fetal Delivery, Live In-Utero', false, false) +   CNPRC.Utils.legendEntry('DN', 'Dead Non Vaginal', false, true) +
            CNPRC.Utils.legendEntry('e', 'Estimated', true, false) +    CNPRC.Utils.legendEntry('FN','Found at Necropsy', false, false) +               CNPRC.Utils.legendEntry('DVX', 'Dead Vaginal Experimental', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('FX','Live, Term, Euthanized at Birth', false, false) + CNPRC.Utils.legendEntry('DNX', 'Dead Non Vaginal Experimental', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('K' ,'Medical Cull', false, false) +                    CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('KI','Possible Medical Cull, In Utero', false, false) + CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('M' ,'Medical Cull, Diagnostic', false, false) +        CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('ND','Neonatal Death', false, false) +                  CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('NT','No Tissue', false, false) +                       CNPRC.Utils.legendEntry('', '', false, true) +
            CNPRC.Utils.legendEntry(' ', ' ', true, false) +            CNPRC.Utils.legendEntry('S' ,'Surgical Cull', false, false) +                   CNPRC.Utils.legendEntry('', '', false, true) +
            '</table>'
        }]
    });
};

EHR.reports.diarrheaCalendar = function (panel, tab, viewName) {
    var filterArray = panel.getFilterArray(tab);
    var subjects = filterArray.subjects;
    var columnName = 'Id';

    if (filterArray.nonRemovable.length > 0)
        columnName = filterArray.nonRemovable[0].getColumnName();


    if ( !Ext4.isDefined(subjects) || subjects.length > 10 ) {
        tab.add({
            html: 'Please select between 1 and 10 subjects. If more than 10 subjects are selected, only the first 10 will be shown.',
            style: 'padding-bottom: 20px;',
            border: false
        });
    }

    if ( Ext4.isDefined(subjects) && subjects.length > 10 ) {
        subjects = subjects.slice(0, 10);
    }

    if ( Ext4.isDefined(subjects) ) {
        subjects.forEach(function(subj){
            var individualFilters = filterArray.nonRemovable.slice();  // copy array
            individualFilters.push(LABKEY.Filter.create('Id', subj, LABKEY.Filter.Types.EQUAL));

            tab.add({
                xtype: 'ldk-querycmp',
                style: 'margin-bottom:10px;',
                queryConfig: panel.getQWPConfig({
                    schemaName: 'study',
                    queryName: 'diarrheaCalendar',
                    viewName: viewName,
                    title: 'Diarrhea Calendar: ' + subj,
                    filters: individualFilters,
                    removeableFilters: filterArray.removable
                })
            });
        }, this);

        tab.add({
            xtype: 'ldk-webpartpanel',
            title: 'Legend',
            items: [{
                border: false,
                html: '<table class="ehr-legend">' +
                CNPRC.Utils.legendTitle('Code', true, false) +
                CNPRC.Utils.legendEntry('D', 'Diarrhea Observation (from Morning Health Observations)', true, false) +
                CNPRC.Utils.legendEntry('Dc', 'Diarrhea Clinical Observation (from Clinical Observations)', true, false) +
                CNPRC.Utils.legendEntry('D*', 'Diarrhea Observation Confirmation (from Morning Health Observations confirmations) (not yet implemented)', true, false) +
                CNPRC.Utils.legendEntry('M', 'Move - animal relocated', true, false) +
                CNPRC.Utils.legendEntry('+', 'Weight Increase 1% or more per day since last weight', true, false) +
                CNPRC.Utils.legendEntry('-', 'Weight Decrease 1% or more per day since last weight', true, false) +
                CNPRC.Utils.legendEntry('~', 'Weight, with no Increase/Decrease', true, false) +
                '</table>'
            }]
        });
    }
};