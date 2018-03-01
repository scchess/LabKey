/*
 * Copyright (c) 2012-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");
var Ext = require("Ext4").Ext;

exports.init = function(EHR){
    //NOTE: this is getting passed the LK errors object, rather than the EHR wrapper
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'cage', function(helper, scriptErrors, row, oldRow){
        //pad cage to 4 digits if numeric
        if(row.cage && !isNaN(row.cage)){
            row.cage = EHR.Server.Utils.padDigits(row.cage, 4);
        }

        if(row.room)
            row.room = row.room.toLowerCase();

        row.location = row.room;
        if(row.cage)
            row.location += '-' + row.cage;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'Treatment Orders', function(event, helper){
        helper.setScriptOptions({
            removeTimeFromDate: true,
            removeTimeFromEndDate: true
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Treatment Orders', function(helper, scriptErrors, row, oldRow){
        if (row.date && row.enddate){
            var startDate = EHR.Server.Utils.normalizeDate(row.date);
            var endDate = EHR.Server.Utils.normalizeDate(row.enddate);

            if (startDate - endDate == 0 ){
                EHR.Server.Utils.addError(scriptErrors, 'enddate', 'Single Day Treatment', 'INFO');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Drug Administration', function(helper, scriptErrors, row, oldRow){
        if (row.volume && row.concentration){
            var expected = Math.round(row.volume * row.concentration * 1000) / 1000;
            if (Math.abs(row.amount - expected) > 0.2){ //allow for rounding
                EHR.Server.Utils.addError(scriptErrors, 'amount', 'Amount does not match volume for this concentration. Expected: '+expected, 'INFO');
                //EHR.Server.Utils.addError(scriptErrors, 'volume', 'Volume does not match amount for this concentration. Expected: '+expected, 'WARN');
            }
        }

        EHR.Server.Validation.checkRestraint(row, scriptErrors);
    });

    /**
     * A helper that will infer the species based on regular expression patterns and the animal ID
     * @param row The row object, provided by LabKey
     * @param errors The errors object, provided by LabKey
     */
    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, function(helper, scriptErrors, row, oldRow){
        var species;
        if (row.Id && !helper.isQuickValidation() && !helper.isETL())
        {
            if (row.Id.match(/(^rh([0-9]{4})$)|(^r([0-9]{5})$)|(^rh-([0-9]{3})$)|(^rh[a-z]{2}([0-9]{2})$)/))
                species = 'Rhesus';
            else if (row.Id.match(/^cy([0-9]{4})$/))
                species = 'Cynomolgus';
            else if (row.Id.match(/^ag([0-9]{4})$/))
                species = 'Vervet';
            else if (row.Id.match(/^cj([0-9]{4})$/))
                species = 'Marmoset';
            else if (row.Id.match(/^so([0-9]{4})$/))
                species = 'Cotton-top Tamarin';
            else if (row.Id.match(/^pt([0-9]{4})$/))
                species = 'Pigtail';
            else if (row.Id.match(/^pd([0-9]{4})$/)){
                if (row.species)
                species = row.species;
                else
                species = 'Infant';
            }

            //these are to handle legacy data:
            else if (row.Id.match(/(^rha([a-z]{1})([0-9]{2}))$/))
                species = 'Rhesus';
            else if (row.Id.match(/(^rh-([a-z]{1})([0-9]{2}))$/))
                species = 'Rhesus';
            else if (row.Id.match(/^cja([0-9]{3})$/))
                species = 'Marmoset';
            else if (row.Id.match(/^m([0-9]{5})$/))
                species = 'Marmoset';
            else if (row.Id.match(/^tx([0-9]{4})$/))
                species = 'Marmoset';
            //and this is to handle automated tests
            else if (row.Id.match(/^test[0-9]+$/))
                species = 'Rhesus';
            else
                species = 'Unknown';
        }
        row.species = species;

        //check Id format
        if(!helper.isETL() && !helper.isSkipIdFormatCheck()){
            if(row.Id && species){
                if(species == 'Unknown'){
                    EHR.Server.Utils.addError(scriptErrors, 'Id', 'Invalid Id Format', 'INFO');
                }
                else if (species == 'Infant') {
                    species = null;
                }
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Arrival', function(row){
        var description = new Array();

        if (row.source)
            description.push('Source: ' + row.source);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Assignment', function(row){
        //we need to set description for every field
        var description = new Array();

        description.push('Start Date: ' + EHR.Server.Utils.dateToString(row.Date));
        description.push('Removal Date: ' + (row.enddate ? EHR.Server.Utils.dateToString(row.enddate) : ''));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Birth', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.conception)
            description.push('Conception: '+ row.conception);

        if(row.gender)
            description.push('Gender: '+ EHR.Server.Utils.nullToString(row.gender));
        if(row.dam)
            description.push('Dam: '+ EHR.Server.Utils.nullToString(row.dam));
        if(row.sire)
            description.push('Sire: '+ EHR.Server.Utils.nullToString(row.sire));
        if(row.room)
            description.push('Room: '+ EHR.Server.Utils.nullToString(row.room));
        if(row.cage)
            description.push('Cage: '+ EHR.Server.Utils.nullToString(row.cage));
        if(row.cond)
            description.push('Cond: '+ EHR.Server.Utils.nullToString(row.cond));
        if(row.weight)
            description.push('Weight: '+ EHR.Server.Utils.nullToString(row.weight));
        if(row.wdate)
            description.push('Weigh Date: '+ EHR.Server.Utils.nullToString(row.wdate));
        if(row.origin)
            description.push('Origin: '+ row.origin);
        if(row.type)
            description.push('Type: '+ row.type);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Chemistry Results', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.testid)
            description.push('Test: '+EHR.Server.Utils.nullToString(row.testid));
        if (row.method)
            description.push('Method: '+row.method);

        if(row.result)
            description.push('Result: '+EHR.Server.Utils.nullToString(row.result)+' '+EHR.Server.Utils.nullToString(row.units));
        if(row.qualResult)
            description.push('Qual Result: '+EHR.Server.Utils.nullToString(row.qualResult));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Clinical Encounters', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.type)
            description.push('Type: ' + row.type);
        if(row.title)
            description.push('Title: ' + row.title);
        if(row.caseno)
            description.push('CaseNo: ' + row.caseno);
        if(row.major)
            description.push('Is Major?: '+row.major);
        if(row.performedby)
            description.push('Performed By: ' + row.performedby);
        if(row.enddate)
            description.push('Completed: ' + EHR.Server.Utils.datetimeToString(row.enddate));

        //NOTE: only show this for non-final data
        if(row.servicerequested && row.QCStateLabel && EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData === false)
            description.push('Service Requested: ' + row.servicerequested);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Clinical Observations', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.category)
            description.push('Category: ' + row.category);
        if(row.area)
            description.push('Area: ' + row.area);
        if(row.observation)
            description.push('Observation: ' + row.observation);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Clinpath Runs', function(row){
        //we need to set description for every field
        var description = new Array();

        if (row.type)
            description.push('Type: '+row.type);

        if (row.serviceRequested)
            description.push('Service Requested: '+row.servicerequested);

        if (row.sampleType)
            description.push('Sample Type: '+row.sampleType);

        if (row.sampleId)
            description.push('Sample Id: '+row.sampleId);

        if (row.collectedBy)
            description.push('Collected By: '+row.collectedBy);

        if (row.collectionMethod)
            description.push('Collection Method: '+row.collectionMethod);

        if (row.clinremark)
            description.push('Clinical Remark: '+row.clinremark);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Deaths', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.cause)
            description.push('Cause: '+row.cause);
        if(row.manner)
            description.push('Manner: '+row.manner);
        if(row.necropsy)
            description.push('Necropsy #: '+row.necropsy);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Departure', function(row){
        //we need to set description for every field
        var description = new Array();

        if (row.authorize)
            description.push('Authorized By: '+ row.authorize);

        if (row.destination)
            description.push('Destination: '+ row.destination);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Drug Administration', function(row, helper){
        //we need to set description for every field
        var description = new Array();

        if(row.code)
            description.push('Code: '+EHR.Server.Utils.snomedToString(row.code, row.meaning, helper));
        if(row.route)
            description.push('Route: '+row.route);
        if(row.volume)
            description.push('Volume: '+ row.volume+' '+EHR.Server.Utils.nullToString(row.vol_units));
        if(row.amount)
            description.push('Amount: '+ row.amount+' '+EHR.Server.Utils.nullToString(row.amount_units));


        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Hematology Results', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.testid)
            description.push('Test: '+EHR.Server.Utils.nullToString(row.testid));
        if (row.method)
            description.push('Method: '+row.method);

        if(row.result)
            description.push('Result: '+EHR.Server.Utils.nullToString(row.result));

        if(row.qualResult)
            description.push('Qualitative Result: '+EHR.Server.Utils.nullToString(row.qualResult));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Histology', function(row, helper){
        //we need to set description for every field
        var description = new Array();

        if(row.slideNum)
            description.push('Slide No: ' + row.slideNum);
        if(row.tissue)
            description.push('Tissue: ' + EHR.Server.Utils.snomedToString(row.tissue, null, helper));
        if(row.diagnosis)
            description.push('Diagnosis: ' + row.diagnosis);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Housing', function(row){
        //we need to set description for every field
        var description = new Array();

        if (row.room)
            description.push('Room: '+ row.room);
        if (row.cage)
            description.push('Cage: '+ row.cage);
        if (row.cond)
            description.push('Condition: '+ row.cond);

        description.push('In Time: '+ row.Date);
        description.push('Out Time: '+ EHR.Server.Utils.nullToString(row.enddate));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Notes', function(row){
        //we need to set description for every field
        var description = new Array();

        description.push('Start Date: ' + (row.Date ? EHR.Server.Utils.datetimeToString(row.Date) : ''));
        description.push('End Date: ' + (row.EndDate ? EHR.Server.Utils.datetimeToString(row.EndDate) : ''));

        if(row.category)
            description.push('Category: ' + row.category);
        if(row.value)
            description.push('Value: ' + row.value);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Organ Weights', function(row, helper){
        //we need to set description for every field
        var description = new Array();

        if(row.tissue)
            description.push('Organ/Tissue: ' + EHR.Server.Utils.snomedToString(row.tissue, row.tissueMeaning, helper));
        if(row.weight)
            description.push('Weight: ' + row.weight);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Parasitology Results', function(row, helper){
        //we need to set description for every field
        var description = new Array();

        if(row.organism || row.meaning)
            description.push('Organism: '+EHR.Server.Utils.snomedToString(row.organism, row.meaning, helper));
        if (row.method)
            description.push('Method: '+row.method);

        if(row.result)
            description.push('Result: '+EHR.Server.Utils.nullToString(row.result)+' '+EHR.Server.Utils.nullToString(row.units));
        if(row.qualResult)
            description.push('Qual Result: '+EHR.Server.Utils.nullToString(row.qualResult));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Problem List', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.category)
            description.push('Category: '+row.problem_no);

        if(row.problem_no)
            description.push('Problem No: '+row.problem_no);

        description.push('Date Observed: '+EHR.Server.Utils.datetimeToString(row.date));
        description.push('Date Resolved: '+EHR.Server.Utils.datetimeToString(row.enddate));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Tissue Samples', function(row, helper){
        //we need to set description for every field
        var description = new Array();

        if(row.tissue)
            description.push('Tissue: ' + EHR.Server.Utils.snomedToString(row.tissue, helper));
        if(row.qualifier)
            description.push('Qualifier: ' + row.qualifier);
        if(row.diagnosis)
            description.push('Diagnosis: ' + row.diagnosis);
        if(row.recipient)
            description.push('Recipient: ' + row.recipient);
        if(row.container_type)
            description.push('Container: ' + row.container_type);
        if(row.accountToCharge)
            description.push('Account to Charge: ' + row.accountToCharge);
        if(row.ship_to)
            description.push('Ship To: ' + row.ship_to);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Treatment Orders', function(row, helper){
        //we need to set description for every field
        var description = new Array();

        if(row.meaning)
            description.push('Meaning: '+ row.meaning);
        if(row.code || row.snomedMeaning)
            description.push('Code: '+EHR.Server.Utils.snomedToString(row.code, row.snomedMeaning, helper));
        if(row.route)
            description.push('Route: '+ row.route);
        if(row.concentration)
            description.push('Conc: '+ row.concentration+ ' '+ EHR.Server.Utils.nullToString(row.conc_units));
        if(row.dosage)
            description.push('Dosage: '+ row.dosage+ ' '+ EHR.Server.Utils.nullToString(row.dosage_units));
        if(row.volume)
            description.push('Volume: '+ row.volume+ ' '+ EHR.Server.Utils.nullToString(row.vol_units));
        if(row.amount)
            description.push('Amount: '+ row.amount+ ' '+ EHR.Server.Utils.nullToString(row.amount_units));

        description.push('EndDate: '+ (row.enddate ? row.enddate : 'none'));


        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Urinalysis Results', function(row){
        var description = new Array();

        if(row.testid)
            description.push('Test: '+EHR.Server.Utils.nullToString(row.testid));
        if (row.method)
            description.push('Method: '+row.method);

        if(row.result)
            description.push('Result: '+EHR.Server.Utils.nullToString(row.result)+' '+EHR.Server.Utils.nullToString(row.units));
        if(row.qualResult)
            description.push('Qual Result: '+EHR.Server.Utils.nullToString(row.qualResult));

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Weight', function(row){
        //we need to set description for every field
        var description = new Array();

        if(row.weight)
            description.push('Weight: '+row.weight);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Problem List', function(helper, scriptErrors, row){
        //autocalculate problem #
        //TODO: testing needed
        if (!helper.isETL() && row.Id){
            LABKEY.Query.executeSql({
                schemaName: 'study',
                sql: "SELECT MAX(problem_no)+1 as problem_no FROM study.problem WHERE id='"+row.Id+"'",
                //NOTE: remove QC filter because of potential conflicts: +" AND qcstate.publicdata = TRUE",
                success: function(data){
                    if (data && data.rows && data.rows.length==1){
                        //console.log('problemno: '+data.rows[0].problem_no);
                        row.problem_no = data.rows[0].problem_no || 1;
                    }
                    else {
                        row.problem_no = 1;
                    }
                },
                failure: EHR.Server.Utils.onFailure
            });
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'study', 'Blood Draws', function(row){
        //we need to set description for every field
        var description = new Array();

        if (row.quantity)
            description.push('Total Quantity: '+ row.quantity);
        if (row.performedby)
            description.push('Performed By: '+ row.performedby);
    //    if (row.requestor)
    //        description.push('Requestor: '+ row.requestor);
        if (row.billedby)
            description.push('Billed By: '+ row.billedby);
        if (row.assayCode)
            description.push('Assay Code', row.assayCode);
        if (row.tube_type)
            description.push('Tube Type: '+ row.tube_type);
        if (row.num_tubes)
            description.push('# of Tubes: '+ row.num_tubes);
        if (row.additionalServices)
            description.push('Additional Services: '+ row.additionalServices);

        return description;
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.COMPLETE, 'study', 'Deaths', function(event, errors, helper){
        if(helper.getPublicParticipantsModified().length && !helper.isETL()){
            var generateAnEmail = 0;
            var valuesMap = {};
            var r;
            for (var i=0;i<helper.getRows().length;i++){
                r = helper.getRows()[i];
                console.log ('value of r.account '+ r.row.account);
                valuesMap[r.row.Id] = {};
                valuesMap[r.row.Id].death = r.row.date;
                valuesMap[r.row.Id].animalNumber = r.row.Id;
                if (r.row.necropsy) {
                    //populate the enddate
                   // valuesMap[r.row.Id].weight = r.row.weight;
                    valuesMap[r.row.Id].enteredGrant = r.row.account;
                    valuesMap[r.row.Id].project = r.row.project;
                    //valuesMap[r.row.id].necropsyDate= r.row.necropsyDate
                    //console.log('value of row.project '+ r.row.project);
                }

                valuesMap[r.row.Id].notified = hasAnimalNotificationBeenSent(r.row.Id);
                if (valuesMap[r.row.Id].notified <=  0) {
                    generateAnEmail +=  1;
                }
                else {
                    console.log('else in the verifyAssignment');
                    verifyAssignmentUpdate(valuesMap[r.row.Id]);
                }
            }

            if (generateAnEmail > 0) {
                for (var i=0;i<helper.getRows().length;i++){
                    r = helper.getRows()[i];
                    if (valuesMap[r.row.Id].notified) {
                        continue;
                    }

                    var aDate = new Date(valuesMap[r.row.Id].death.getTime());
                    var monthString =  EHR.Server.Utils.getMonthString(aDate.getMonth());
                    var minStr = aDate.getMinutes() >= 10 ? aDate.getMinutes() : '0' + aDate.getMinutes();
                    valuesMap[r.row.Id].deathDate    = aDate.getDate() + ' ' + monthString +  ' ' + aDate.getFullYear();
                    valuesMap[r.row.Id].deathTime    = aDate.getHours() + ':' + minStr;
                    valuesMap[r.row.Id].animalNumber = r.row.Id;
                    valuesMap[r.row.Id].manner       = r.row.manner;
                    valuesMap[r.row.Id].necropsy     = r.row.necropsy;

                    if (r.row.necropsy && r.row.weight) {
                     //populate the enddate
                         addIndication(r.row.Id);
                         valuesMap[r.row.Id].weight = r.row.weight;
                         valuesMap[r.row.Id].enteredGrant = r.row.account;
                    }
                    valuesMap[r.row.Id].cause        = r.row.cause;

                    //Get weight for animal
                    if (!r.row.necropsy){
                        LABKEY.Query.selectRows({
                            schemaName:'study',
                            queryName:'Weight',
                            filterArray:[
                                LABKEY.Filter.create('Id', r.row.Id, LABKEY.Filter.Types.EQUAL)
                            ],
                            scope:this,
                            success: function(data) {
                                if (data.rows && data.rows.length) {
                                    var wRow = data.rows[0];
                                    valuesMap[r.row.Id].weight  = wRow.weight;
                                }
                            }
                        });
                    }

                    //Get Grant Number(s)
                    LABKEY.Query.selectRows({
                        schemaName:'study',
                        queryName:'assignment',
                        filterArray:[LABKEY.Filter.create('Id', r.row.Id, LABKEY.Filter.Types.EQUAL),
                            LABKEY.Filter.create('enddate', r.row.date, LABKEY.Filter.Types.DATE_EQUAL)
                        ],
                        scope:this,
                        success: function(data) {
                            if (data && data.rows.length) {
                                if (data.rows.length > 1) {
                                    valuesMap[r.row.Id].grant = [];
                                    for (var x = 0; x<data.rows.length; x++) {
                                        LABKEY.Query.selectRows({
                                            schemaName:'ehr',
                                            queryName: 'project',
                                            filterArray:[
                                                LABKEY.Filter.create('project', data.rows[x].project, LABKEY.Filter.Types.EQUAL)
                                            ],
                                            scope:this,
                                            success: function(data) {
                                                if (data && data.rows.length) {
                                                    valuesMap[r.row.Id].grant.push(data.rows[0].account);
                                                    console.log('added ' + data.rows[0].account + ' to list of grantNumbers for ' + r.row.Id);
                                                }
                                            }
                                        });

                                    }
                                } else {
                                    LABKEY.Query.selectRows({
                                        schemaName:'ehr',
                                        queryName: 'project',
                                        filterArray: [
                                            LABKEY.Filter.create('project', data.rows[0].project, LABKEY.Filter.Types.EQUAL)
                                        ],
                                        scope: this,
                                        success: function(data) {
                                            if (data && data.rows.length) {
                                                valuesMap[r.row.Id].grant = data.rows[0].account;
                                                console.log(data.rows[0].account + ' is the sole grant number associated with ' + r.row.Id);
                                            }
                                        }
                                    });

                                }
                            }
                        }
                    });

                    //Get Necropsy Date
                    LABKEY.Query.selectRows({
                        schemaName: 'study',
                        queryName: 'necropsy',
                        filterArray:[LABKEY.Filter.create('Id', r.row.Id, LABKEY.Filter.Types.EQUAL)],
                        scope: this,
                        success: function(data) {
                            if (data && data.rows.length) {
                                var nDate= data.rows[0].date;
                                aDate = new Date(nDate);
                                monthString = EHR.Server.Utils.getMonthString(aDate.getMonth());
                                valuesMap[r.row.Id].necropsyDate = aDate.getDate() + ' ' + monthString + ' ' + aDate.getFullYear();
                                if (valuesMap[r.row.Id].enteredGrant == undefined || valuesMap[r.row.Id].enteredGrant == null) {
                                    console.log('No grant number supplied... defaulting to: ' + data.rows[0].account);
                                    valuesMap[r.row.Id].enteredGrant = data.rows[0].account;
                                }
                            }else {
                                    var aDate = new Date(r.row.necropsyDate);
                                    var monthString =  EHR.Server.Utils.getMonthString(aDate.getMonth());
                                    //var minStr = aDate.getMinutes() >= 10 ? aDate.getMinutes() : '0' + aDate.getMinutes();
                                    valuesMap[r.row.Id].necropsyDate    = aDate.getDate() + ' ' + monthString +  ' ' + aDate.getFullYear();
                                    //valuesMap[r.row.id].necropsyDate= r.row.necropsyDate
                                }
                        }
                    });
                    //Get Gender & replacement Fee
                    var gCode;
                    console.log ('value of gcode '+ gCode);
                    LABKEY.Query.selectRows({
                        schemaName:'study',
                        queryName:'demographics',
                        scope:this,
                        filterArray:[LABKEY.Filter.create('Id', r.row.Id, LABKEY.Filter.Types.EQUAL)],
                        success: function(data) {
                            if (data && data.rows.length) {
                                var gRow = data.rows[0];
                                console.log('value of gender:'+ gRow.gender);
                                gCode = gRow.gender;
                                if (gRow.prepaid && gRow.prepaid.length) {
                                    valuesMap[r.row.Id].fee = 'Animal replacement fee was paid by ' + gRow.prepaid;
                                } else {
                                    valuesMap[r.row.Id].fee = 'Animal replacement fee to be paid (not prepaid animal)';
                                }
                            }
                        }
                    });
                    if (gCode == null){
                        //request for specify gender of the animal
                        EHR.Server.Utils.addError(errors, 'gender', 'please add gender', 'INFO');
                        console.log ('no gender');
                    }
                    LABKEY.Query.selectRows({
                        schemaName:'ehr_lookups',
                        queryName:'gender_codes',
                        scope:this,
                        filterArray:[LABKEY.Filter.create('code', gCode, LABKEY.Filter.Types.EQUAL)],
                        success: function(data) {
                            if (data && data.rows.length) {
                                var gRow = data.rows[0];
                                valuesMap[r.row.Id].gender = gRow.meaning;
                            }
                        }
                    });


                }
                var  theMsg = new String();;
                var recipients = [];
                for (var k in valuesMap){
                    var obj = valuesMap[k];
                    if (obj.notified) {
                        continue;
                    }
                    var principalIDs;

                    theMsg += "Necropsy Number:            " + obj.necropsy + "<br> " ;
                    theMsg += "Necropsy Date  :            " + obj.necropsyDate + "<br>" ;
                    theMsg += "Animal Number  :            " + obj.animalNumber + "<br>" ;
                    theMsg += "Weight:                     " + obj.weight + " kg <br>";
                    theMsg += "Sex:                        " + obj.gender + "<br>";
                    theMsg += "Date of Death:              " + obj.deathDate + "<br>";
                    theMsg += "Time of Death:              " + obj.deathTime + "<br>";
                    theMsg += "Death:                      " + obj.cause + "<br>";
                    theMsg += "Grant #:                    " + obj.enteredGrant + "<br>";
                    if (obj.cause == 'Clinical') {
                        //Clinical Deaths get the following hard-coded animal replacement fee text
                        theMsg += "Animal Replacement Fee:     " + "No Animal replacement fee to be paid (clinical death) <br>";
                    } else {
                        theMsg += "Animal Replacement Fee:     " + obj.fee   + "<br>";
                    }
                    theMsg += "Manner of Death:            " + obj.manner + "<br> <br> ";

                    //TODO: Implement after change to project table
                    //principalIDs = getPrincipalInvestigators(obj.animalNumber);
                    //if (principalIDs.length) {
                    //   for (var x=0; x<principalIDs.length;x++){
                    //   	recipients.push(LABKEY.Message.createPrincipalIdRecipient(LABKEY.Message.recipientType.to, principalIDs[x]));
                    //   }
                    // } else  {
                    //Must be a more efficient way, but for now see if there are active assignments where release date is assigned
                    //the participant's expiration date
                    //    principalIDs = getPrincipals(obj);
                    //    if (principalIDs.length) {
                    //     for (var x=0; x<principalIDs.length;x++) {
                    //       recipients.push(LABKEY.Message.createPrincipalIdRecipient(LABKEY.Message.recipientType.to, principalIDs[x]));
                    //     }
                    //     }
                    //    }
                }
                var openingLine;
                if (generateAnEmail > 1) {
                    openingLine = 'The following animals have been marked as dead:<br><br>' ;
                } else {
                    openingLine = 'The following animal has been marked as dead:<br><br>';
                }
                EHR.Server.Utils.sendEmail({
                    notificationType: 'Animal Death',

                    msgContent: openingLine +
                            theMsg +
                            '<p></p><a href="'+LABKEY.ActionURL.getBaseURL()+'ehr' + LABKEY.ActionURL.getContainer() + '/animalHistory.view#inputType:multiSubject&subjects:'+helper.getPublicParticipantsModified().join(';')+'&combineSubj:true&activeReport:abstract' +
                            '">Click here to view them</a>.',
                    msgSubject: 'Death Notification',
                    recipients: recipients
                });
            }
        }

        function getPrincipalIDByProject(projectID) {
            //Given the project id, we are going to search for the principal investigators
            //which is a string format for some reason.  Finding that string, we determine
            //if the project has joint PIs, which is specified as 'name1/name2'.  Will search
            //for userids based on last name.  This method of locating PIs should  be changed
            //by applying not the lastname of PI in project table, but userId of PI in project table as
            //that would make this more robust.
            var principals = [];
            LABKEY.Query.selectRows({
                schemaName: 'ehr',
                queryName: 'project',
                filterArray:[
                    LABKEY.Filter.create('project', projectID, LABKEY.Filter.Types.EQUAL)
                ],
                scope:this,
                success: function(data) {
                    if (data && data.rows && data.rows.length) {
                        var projRow = data.rows[0];
                        console.log('Project ' + projectID + ' has investigator = ' + projRow.inves);
                        var investStr = projRow.inves;
                        if (investStr.indexOf("/") > 0 ) {
                            //Joint PIs identified by '/'
                            var lineSplit = investStr.split("/");
                            principals.push(getUserID(lineSplit[0]));
                            principals.push(getUserID(lineSplit[1]));
                        } else {
                            principals.push(getUserID(investStr));
                        }
                    }
                }
            });
            console.log('Number of principal investigators for project '+ projectID + ': ' + principals.length);
            return principals;
        }

        function getUserID(lastName) {
            var userId;
            LABKEY.Query.selectRows({
                schemaName:'core',
                queryName: 'users',
                filterArray:[
                    LABKEY.Filter.create('LastName', lastName, LABKEY.Filter.Types.STARTS_WITH)
                ],
                scope:this,
                success: function(data) {
                    if (data && data.rows && data.rows.length) {
                        var row = data.rows[0];
                        userId = row.UserId;
                    } else {
                        console.log('unable to find a user with lastname = ' + lastName);
                    }
                }
            });
            return userId;
        }
        function hasAnimalNotificationBeenSent(animalID) {
            var retValue = 0;
            LABKEY.Query.selectRows({
                schemaName:'study',
                queryName:'Deaths',
                filterArray:[
                    LABKEY.Filter.create('Id', animalID, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK)
                ],
                scope:this,
                success: function(data){
                    if (data && data.rows && data.rows.length) {
                        console.log('No notification of the death of animal ' + animalID + ' has been created.');
                    } else {
                        console.log("Notification was sent");
                        retValue = 1;
                    }
                }
            });
            return retValue;
        }
        function addIndication(animalID) {
            var obj = {Id: animalID };
            LABKEY.Query.selectRows({
                schemaName:'study',
                queryName:'Deaths',
                filterArray:[
                    LABKEY.Filter.create('Id', animalID, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK)
                ],
                scope:this,
                success: function(data){
                    if (data && data.rows && data.rows.length) {
                        console.log('No notification of the death of animal ' + animalID + ' has been created.');
                        var r = data.rows[0];
                        var obj = {
                            Id: r.Id,
                            //project: r.project,
                            date: r.date,
                            cause: r.causeofdeath,
                            manner: r.mannerofdeath,
                            necropsy: r.caseno,
                            parentid: r.objectid,
                            lsid: r.lsid,
                            enddate: r.date };
                        //update the row
                        LABKEY.Query.updateRows({
                            schemaName:'study',
                            queryName:'Deaths',
                            scope:this,
                            rows: [obj],
                            success: function(data){
                                console.log('Success updating ' + animalID + ' in death table');
                            },
                            failure: EHR.Server.Utils.onFailure
                        });
                    }
                }
            });
        }
        function getPrincipals(object) {

            var pInvestigators = [];
            console.log('looking for PIs of animal ' + object.animalNumber);
            LABKEY.Query.selectRows({
                schemaName:'study',
                queryName: 'Assignment',
                viewName: 'Active Assignments',
                filterArray:[
                    LABKEY.Filter.create('Id', object.animalNumber, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('enddate', object.death, LABKEY.Filter.Types.DATE_EQUAL)
                ],
                scope:this,
                success: function(data) {
                    if (data && data.rows && data.rows.length) {
                        var row ;
                        for (var cnt = 0; cnt < data.rows.length; cnt++) {
                            row = data.rows[cnt];
                            if (row.project) {
                                console.log('Looking for PI(s) of project: ' + row.project);
                                var principalIDs = getPrincipalIDByProject(row.project);
                                if (principalIDs.length) {
                                    for (var idx = 0;idx < principalIDs.length;idx++) {
                                        pInvestigators.push(principalIDs[idx]);
                                    }
                                }
                            }
                        }

                    }
                }
            });
            console.log ('Located ' + pInvestigators.length + ' PIs  for animal ' + object.animalNumber);
            return pInvestigators;

        }

        function getPrincipalInvestigators(animalID) {
            var pInvestigators = [];
            console.log('looking for PIs of animal ' + animalID);
            LABKEY.Query.selectRows({
                schemaName:'study',
                queryName: 'Assignment',
                viewName: 'Active Assignments',
                filterArray:[
                    LABKEY.Filter.create('Id', animalID, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK)
                ],
                scope:this,
                success: function(data) {
                    if (data && data.rows && data.rows.length) {
                        var row ;
                        for (var idx = 0; idx < data.rows.length; idx++) {
                            row = data.rows[idx];
                            if (row.project) {
                                console.log('Looking for PI(s) of project: ' + row.project);
                                var principalIDs = getPrincipalIDByProject(row.project);
                                if (principalIDs.length) {
                                    for (var idx = 0;idx < principalIDs.length;idx++) {
                                        pInvestigators.push(principalIDs[idx]);
                                    }
                                }
                            }
                        }

                    }
                }
            });
            console.log ('Located ' + pInvestigators.length + ' PIs  for animal ' + animalID);
            return pInvestigators;
        }
        function verifyAssignmentUpdate(subject ) {
            //Verify that animal is in no active assignments
            LABKEY.Query.selectRows({
                schemaName:'study',
                queryName:'Assignment',
                filterArray:[
                    LABKEY.Filter.create('Id', subject.animalNumber, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK)
                ],
                scope:this,
                success: function(data) {
                    if (data && data.rows && data.rows.length) {
                        console.log(data.rows.length + ' entries');
                        var row ;
                        for (var idx = 0; idx < data.rows.length; idx++) {
                            row = data.rows[idx];
                            var x = subject.death.toGMTString();
                            var obj = { lsid: row.lsid, Id: subject.animalNumber, enddate: x};
                            //Update row in assignment table with an enddate
                            LABKEY.Query.updateRows({
                                schemaName:'study',
                                queryName:'Assignment',
                                scope:this,
                                rows: [obj],
                                success: function(data){
                                    console.log('Success verifying assignments for ' + subject.animalNumber );
                                },
                                failure: EHR.Server.Utils.onFailure
                            });

                        }

                    }
                    console.log(subject.animalNumber + '  assignment termination verified');
                }
            });
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Housing', function(helper, scriptErrors, row, oldRow){
        if (row.cage){
            row.cage = row.cage.toLowerCase();
        }
        if (!helper.isETL()){
            if (row.cond && row.cond.match(/x/) && !row.remark){
                EHR.Server.Utils.addError(scriptErrors, 'cond', 'If you pick a special housing condition (x), you need to enter a remark stating the type');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Irregular Observations', function(helper, scriptErrors, row, oldRow) {
        //
        //  Enforce that a trauma location must always be supplied when "Trauma" is selected as an "other observation".
        //
        console.log("TRIGGER", row);
        if ( row.other ) {
            var other = row.other.split(",");
            if ( (other.length > 0) && (other.indexOf("T") >= 0) ) {
                if ( (row.tlocation === null) || !(row.tlocation) ) {
                    EHR.Server.Utils.addError(scriptErrors, 'tlocation', "You must specify a location when indicating trauma to an animal.");
                }
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'protocol', function(helper, scriptErrors, row, oldRow){
        if (row.protocol)
            row.protocol = row.protocol.toLowerCase();
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Blood Draws', function(helper, scriptErrors, row, oldRow){
        if (row.additionalServices){
            //We do not permit requests of 6mL in EDTA with CBC
            if (row.tube_type == 'EDTA' && row.tube_vol === 6 && row.additionalServices.indexOf('CBC') >= 0) {
                EHR.Server.Utils.addError(scriptErrors, 'tube_type', 'May not request draw of 6mL in EDTA with CBC', 'ERROR');
            }
        }
    });

    function checkBehavior(row, errors, scriptContext, targetField){
        if (row.behatype=='SIB'){
            switch(row.category){
                case 'SDR': return true;
                case 'SDU': return true;
                case 'SD': return true;
                case 'SIB1': return true;
                case 'SIB2': return true;
                case 'SIB3': return true;
                case 'SDR': return true;
                case 'SIBR': return true;
                default: EHR.Server.Utils.addError(errors, (targetField || 'Id'), 'This category does not match the type selected', 'ERROR');
                    return false;

            }
            /*if (row.category =='SDR' || row.category== 'SDU' || row.category=='SD'){
            console.log ('correct conbination of SIB and SDU');
            return true;
            }
            else{
                EHR.Server.Utils.addError(errors, (targetField || 'Id'), 'This category does not match the type selected', 'ERROR');
                return false
            }*/
        }
        if (row.behatype=='Abnormal'){
            switch(row.category){
                case 'Stereotypy': return true;
                case 'Alopecia': return true;
                case 'Digit/Appendage stuck': return true;
                case 'Other': return true;
                default: EHR.Server.Utils.addError(errors, (targetField || 'Id'), 'This category does not match the type selected', 'ERROR');
                    return false;
            }
        }
        if (row.behatype=='Socialization'){
            switch(row.category){
                case 'T1': return true;
                case 'T2': return true;
                case 'T3': return true;
                case 'PC': return true;
                case 'V': return true;
                case 'Repair': return true;
                case 'Other': return true;
                default: EHR.Server.Utils.addError(errors, (targetField || 'Id'), 'This category does not match the type selected', 'ERROR');
                    return false;
            }
        }if (row.behatreatment=='Modify Caging'){
            if(row.behatype=='Abnormal' && row.category){
                return true
            }else{
                EHR.Server.Utils.addError(errors, (targetField || 'Id'), 'This category does not match the type selected', 'ERROR');
                return false;

            }
        }
    }

    function getHousingSQL(row)
    {
        var date = row.Date;
        date = EHR.Server.Utils.normalizeDate(date);
        var sqlDate = LABKEY.Query.sqlDateTimeLiteral(date);

        var sql = "SELECT Id, room, cage, lsid FROM study.housing h " +
                "WHERE h.room='" + row.room + "' AND " +
                "h.date <= " + sqlDate + " AND " +
                "(h.enddate >= " + sqlDate + " OR h.enddate IS NULL) AND " +
                "h.qcstate.publicdata = true ";

        if (row.cage)
            sql += " AND h.cage='" + row.cage + "'";
        return sql;
    }

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'cage_observations', function(helper, scriptErrors, row, oldRow){
        row.performedby = row.performedby || row.userid || null;

        if(row.cage && !isNaN(row.cage)) {
            row.cage = EHR.Server.Utils.padDigits(row.cage, 4);
        }

        // Do not allow someone to mark a cage as okay with observations.
        if(row.no_observations && row.feces) {
            EHR.Server.Utils.addError(scriptErrors, 'no_observations', 'You cannot mark a cage as "OK" if there is an abnormal feces observation.')
        }

        //verify an animal is housed here
        if(row.Date && row.room) {
            var sql = getHousingSQL(row);
            LABKEY.Query.executeSql({
                schemaName: 'study',
                sql: sql,
                success: function(data) {
                    if(!data || !data.rows || !data.rows.length) {
                        if(!row.cage)
                            EHR.Server.Utils.addError(scriptErrors, 'room', 'No animals are housed in this room on this date', 'WARN');
                        else
                            EHR.Server.Utils.addError(scriptErrors, 'cage', 'No animals are housed in this cage on this date', 'WARN');
                    }
                },
                failure: EHR.Server.Utils.onFailure
            });
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_INSERT, 'ehr', 'cage_observations', function(helper, scriptErrors, row, oldRow){
        if(!helper.isETL()){
            row.Date = EHR.Server.Utils.normalizeDate(row.Date);

            // We are a room okay ob if no_observations is true and there is no "cage" in the row.
            var roomok_obv = ( (row.no_observations === true) && !("cage" in row) );

            //
            // Find all animals assigned to these rooms/cages and copy the observations to them.  However, don't copy
            // the data to the animals, if the room is being marked as okay.
            //
            if(row.Date && row.room && !roomok_obv ){
                var sql = getHousingSQL(row);
                var toInsert = [];
                LABKEY.Query.executeSql({
                    schemaName: 'study',
                    sql: sql,
                    success: function(data){
                        if(data && data.rows && data.rows.length){
                            var obj;
                            LABKEY.ExtAdapter.each(data.rows, function(r){
                                obj = {
                                    Id: r.Id,
                                    QCStateLabel: row.QCStateLabel,
                                    RoomAtTime: r.room,
                                    date: new Date(row.date),
                                    observationRecord: row.objectid,
                                    housingRecord: r.lsid,
                                    remark: row.remark,
                                    taskid: row.taskid,
                                    performedby: row.performedby,
                                    feces: row.feces
                                };

                                if(row.cage) {
                                    obj.CageAtTime = r.cage;
                                }

                                toInsert.push(obj);
                            }, this);
                        }
                        else {
                            console.log('No animals found in this room/cage: '+row.room + '/'+row.cage)
                        }
                    },
                    failure: EHR.Server.Utils.onFailure
                });

                if (toInsert.length){
                    LABKEY.Query.insertRows({
                        schemaName: 'study',
                        queryName: 'Cage Observations',
                        rows: toInsert,
                        scope: this,
                        success: function (data) {
                            console.log('Success Cascade Inserting')
                        },
                        failure: EHR.Server.Utils.onFailure
                    });
                }
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPDATE, 'ehr', 'cage_observations', function(helper, scriptErrors, row, oldRow){
        //find animals overlapping with this record
        if(row.Date && row.room && row.rowid){
            //first we locate existing records to avoid unnecessary inserts
            var existingRecords = [];
            var distinctIds = [];
            var existingRecordMap = {};
            LABKEY.Query.selectRows({
                schemaName: 'study',
                queryName: 'Cage Observations',
                filterArray: [
                    LABKEY.Filter.create('observationRecord', row.objectid, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('qcstate/label', 'Delete Requested', LABKEY.Filter.Types.NEQ)
                ],
                columns: 'lsid,id,date,remark,feces',
                scope: this,
                success: function(data){
                    LABKEY.ExtAdapter.each(data.rows, function(r){
                        distinctIds.push(r.Id);
                        //NOTE: we assume there should only be one child per ID
                        existingRecordMap[r.Id] = r;
                        existingRecords.push(r);
                    }, this);

                    var unique = [];
                    for(var i=0; i<distinctIds.length; i++) {
                        if(unique.indexOf(distinctIds[i]) == -1)
                            unique.push(distinctIds[i]);
                    }
                    distinctIds = unique;
                },
                failure: EHR.Server.Utils.onFailure
            });

            //then we find records that should exist
            var sql = "SELECT Id, room, cage, lsid FROM study.housing h " +
                    "WHERE h.room='"+row.room+"' AND " +
                    "h.date <= '"+row.Date+"' AND " +
                    "(h.enddate >= '"+row.Date+"' OR h.enddate IS NULL) AND " +
                    "h.qcstate.publicdata = true ";

            if(row.cage)
                sql += " AND h.cage='"+row.cage+"'";
            //console.log(sql);
            var toInsert = [];
            var toUpdate = [];
            var toDelete = [];
            var foundIds  = {};
            LABKEY.Query.executeSql({
                schemaName: 'study',
                sql: sql,
                success: function(data){
                    if(data && data.rows && data.rows.length){
                        var obj;
                        LABKEY.ExtAdapter.each(data.rows, function(r){
                            foundIds[r.Id] = 1;

                            //only insert the row if it doesnt exist
                            if(!existingRecordMap[r.Id]){
                                obj = {Id: r.Id, QCStateLabel: row.QCStateLabel, RoomAtTime: r.room, date: new Date(row.date), observationRecord: row.objectid, housingRecord: r.lsid, remark: row.remark, taskid: row.taskid, performedby: row.performedby, feces: row.feces};

                                if(row.cage)
                                    obj.CageAtTime = r.cage;

                                toInsert.push(obj);
                            }
                            else {
                                obj = {lsid: existingRecordMap[r.Id].lsid, Id: r.Id, QCStateLabel: row.QCStateLabel, RoomAtTime: r.room, date: new Date(row.date), observationRecord: row.objectid, housingRecord: r.lsid, remark: row.remark, taskid: row.taskid, performedby: row.performedby, feces: row.feces};
                                toUpdate.push(obj);
                            }
                        }, this);
                    }
                    else {
                        console.log('No animals found in this room/cage: '+row.room + '/'+row.cage)
                    }
                },
                failure: EHR.Server.Utils.onFailure
            });


            LABKEY.ExtAdapter.each(existingRecords, function(r){
                if(!foundIds[r.Id]){
                    //NOTE: until delete performance is improved, we will change the QCstate instead of directly deleting
                    //toDelete.push(r);

                    delete r.QCState;
                    r.QCStateLabel = 'Delete Requested';
                    toUpdate.push(r);
                }
            }, this);

            if(toInsert.length){
                LABKEY.Query.insertRows({
                    schemaName: 'study',
                    queryName: 'Cage Observations',
                    rows: toInsert,
                    scope: this,
                    success: function(data){
                        console.log('Success Cascade Inserting')
                    },
                    failure: EHR.Server.Utils.onFailure
                });
            }

            if(toUpdate.length){
                LABKEY.Query.insertRows({
                    schemaName: 'study',
                    queryName: 'Cage Observations',
                    rows: toUpdate,
                    scope: this,
                    success: function(data){
                        console.log('Success Cascade Updating')
                    },
                    failure: EHR.Server.Utils.onFailure
                });
            }

            if(toDelete.length){
                LABKEY.Query.deleteRows({
                    schemaName: 'study',
                    queryName: 'Cage Observations',
                    rows: toUpdate,
                    scope: this,
                    success: function(data){
                        console.log('Success Cascade Deleting')
                    },
                    failure: EHR.Server.Utils.onFailure
                });
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_DELETE, 'ehr', 'cage_observations', function(helper, scriptErrors, row, oldRow){
        if(!helper.isETL()){
            var toDelete = [];
            if(row.objectid){
                LABKEY.Query.selectRows({
                    schemaName: 'study',
                    queryName: 'Cage Observations',
                    filterArray: [
                        LABKEY.Filter.create('observationRecord', row.objectid, LABKEY.Filter.Types.EQUAL)
                    ],
                    scope: this,
                    success: function(data){
                        LABKEY.ExtAdapter.each(data.rows, function(r){
                            toDelete.push({lsid: r.lsid});
                        }, this);
                    },
                    failure: EHR.Server.Utils.onFailure
                });
            }
            //console.log(toDelete);
            if(toDelete.length){
                LABKEY.Query.deleteRows({
                    schemaName: 'study',
                    queryName: 'Cage Observations',
                    rows: toDelete,
                    scope: this,
                    success: function(data){
                        console.log('Success Cascade Deleting');
                    },
                    failure: EHR.Server.Utils.onFailure
                });
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.DESCRIPTION, 'ehr', 'cage_observations', function(row){
        var description = ['Cage Observation'];

        if(row.feces)
            description.push('Feces: '+row.feces);

        return description;
    });
}