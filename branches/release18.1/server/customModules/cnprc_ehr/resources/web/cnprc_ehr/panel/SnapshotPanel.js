/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('CNPRC_EHR.panel.SnapshotPanel', {
    extend: 'EHR.panel.SnapshotPanel',
    alias: 'widget.cnprc_ehr-snapshotpanel',

    getItems: function(){
        return [
            this.getBaseItems()
        ];
    },

    getBaseItems: function () {
        return {
            xtype: 'container',
            defaults: {
                xtype: 'container',
                border: false
            },
            items: [{
                html: '<h4>Summary</h4>'
            }, {
                layout: 'column',
                defaults: {
                    xtype: 'container',
                    columnWidth: 0.3
                },
                items: [{
                    defaults: {
                        xtype: 'displayfield',
                        labelWidth: this.defaultLabelWidth,
                        labelStyle: 'text-align: right; font-weight: bold;',
                        labelSeparator: ''
                    },
                    items: [{
                        fieldLabel: 'Sex',
                        name: 'gender'
                    }, {
                        fieldLabel: 'Birth',
                        name: 'birth'
                    }, {
                        fieldLabel: 'Birth Con No',
                        name: 'birthConNo'
                    }, {
                        fieldLabel: 'Dam ID',
                        name: 'damId'
                    }, {
                        fieldLabel: 'Sire ID',
                        name: 'sireId'
                    }, {
                        fieldLabel: 'Acquisition',
                        name: 'acquisition'
                    }, {
                        fieldLabel: 'Death',
                        name: 'death'
                    }, {
                        fieldLabel: 'Departure',
                        name: 'departure'
                    }, {
                        fieldLabel: 'Age Today',
                        name: 'ageToday'
                    },
                       {
                        fieldLabel: 'Acquisition Age',
                        name: 'acquisitionAge'
                    }, {
                        fieldLabel: 'Time at CNPRC',
                        name: 'timeAtCnprc'
                    },{
                        fieldLabel: 'Age at Departure/Death',
                        name: 'ageAtDeparture'
                    }]
                }, {
                    defaults: {
                        xtype: 'displayfield',
                        labelWidth: this.defaultLabelWidth,
                        labelStyle: 'text-align: right; font-weight: bold;',
                        labelSeparator: ''
                    },
                    items: [{
                        fieldLabel: 'Location',
                        name: 'location'
                    }, {
                        fieldLabel: 'Weight',
                        name: 'weight'
                    }, {
                        fieldLabel: 'Generation',
                        name: 'generation'
                    }, {
                        fieldLabel: 'Previous ID',
                        name: 'previousId'
                    }, {
                        fieldLabel: 'Body Condition',
                        name: 'bodyCondition'
                    }, {
                        fieldLabel: 'TB Test',
                        name: 'tbTest'
                    }, {
                        fieldLabel: 'Serum Bank',
                        name: 'serumBank'
                    }, {
                        fieldLabel: 'Harvest',
                        name: 'harvest'
                    }, {
                        fieldLabel: 'SPF Status',
                        name: 'spfStatus'
                    }, {
                        fieldLabel: 'Colony',
                        name: 'colony'
                    }, {
                        fieldLabel: 'Breeding Group',
                        name: 'breedingGroup'
                    }, {
                        fieldLabel: 'Perdiem',
                        name: 'perdiem'
                    }]
                },{
                    items: [{
                        html: '<h5><strong>Last Project(s)</strong></h5>'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: '',
                        name: 'lastProjects'
                    }, {
                        html: '<hr><h5><strong>Census Flag(s)</strong></h5>'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: '',
                        name: 'censusFlags'
                    },{
                        html: '<hr><h5><strong>Pathology Report(s)</strong></h5>'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: '',
                        name: 'pathologyReports'
                    }]
                }

                ]
            }]
        };
    }

,

    appendDataResults: function(toSet, results, id) {
        this.appendDemographicsResults(toSet, results, id);
        this.appendCnprcDemographicsResults(toSet, results);
        this.appendBirthResults(toSet, results.getBirthInfo(), results.getBirth());
        this.appendBirthConNum(toSet, results);
        this.appendParents(toSet, results);
        this.appendArrivalResults(toSet, results.getArrivalInfo());
        this.appendDeath(toSet, results.getDeathInfo());
        this.appendDeparture(toSet, results);
        this.appendLocation(toSet, results);
        this.appendWeight(toSet, results);
        this.appendBCS(toSet, results);
        this.appendTBResults(toSet, results);
        this.appendSerumBank(toSet, results);
        this.appendHarvestDate(toSet, results);
        this.appendSPFStatus(toSet, results);
        this.appendColony(toSet, results);
        this.appendBreedingGroup(toSet, results);
        this.appendPerDiem(toSet, results);
        this.appendHousingIntervals(toSet, results);
        this.appendLastProjects(toSet, results.getLastProjects());
        this.appendCensusFlags(toSet, results.getCensusFlags());
        this.appendPathologyReports(toSet, results.getPathologyReports());
    },

    appendDemographicsResults: function(toSet, row, id){
        if (!row){
            console.log('Id not found');
            return;
        }

        var animalId = row.getId() || id;
        if (!Ext4.isEmpty(animalId)){
            toSet['animalId'] = LABKEY.Utils.encodeHtml(id);
        }
        if (row.getGender())
            toSet['gender'] = LABKEY.Utils.encodeHtml(row.getGender());
        if (row.getDam())
            toSet['dam'] = LABKEY.Utils.encodeHtml(row.getDam());
        if (row.getSire())
            toSet['sire'] = LABKEY.Utils.encodeHtml(row.getSire());
    },

    appendCnprcDemographicsResults: function(toSet, row){
        if (row.getGenerationNumber())
            toSet['generation'] = LABKEY.Utils.encodeHtml(row.getGenerationNumber());
    },

    appendBirthResults: function(toSet, birthResults, birth){
        if (birthResults && birthResults.length){
            var row = birthResults[0];
            var date = LDK.ConvertUtils.parseDate(row.date || birth);
            var text = date ?  date.format(LABKEY.extDefaultDateFormat) : null;
            if (text){
                var location = row.room;
                if (location)
                    text = text + '&nbsp&nbsp(' + LABKEY.Utils.encodeHtml(location) + ')';

                if (text)
                    toSet['birth'] = text;
            }
        }
        else if (birth){
            var date = LDK.ConvertUtils.parseDate(birth);
            if (date){
                toSet['birth'] = date.format(LABKEY.extDefaultDateFormat);
            }
        }
        else {
            toSet['birth'] = null;
        }
    },

    appendBirthConNum: function(toSet, results){
        if (results.getBirthConceptionNumber())
            toSet['birthConNo'] = LABKEY.Utils.encodeHtml(results.getBirthConceptionNumber());
    },

    appendParents: function(toSet, results){
        if (results.getDam()) {
            var damId;
            if (results.getDamSpecies())
                damId = LABKEY.Utils.encodeHtml(results.getDamSpecies()) + '&nbsp';
            else
                damId = '';
            damId += '<a href="ehr-participantView.view?participantId=' + LABKEY.Utils.encodeHtml(results.getDam()) + '">' + LABKEY.Utils.encodeHtml(results.getDam()) + '</a>';
            var damVerified = results.getFemaleGeneticsVerify();
            if (damId && damVerified)
                damId += '&nbsp v';
            toSet['damId'] = damId;
        }

        if (results.getSire()) {
            var sireId;
            if (results.getSireSpecies())
                sireId = LABKEY.Utils.encodeHtml(results.getSireSpecies()) + '&nbsp';
            else
                sireId = '';

            sireId += '<a href="ehr-participantView.view?participantId=' + LABKEY.Utils.encodeHtml(results.getSire()) + '">' + LABKEY.Utils.encodeHtml(results.getSire()) + '</a>';
            var sireVerified = results.getMaleGeneticsVerify();
            if (sireId && sireVerified)
                sireId += '&nbsp v';
            toSet['sireId'] = sireId;
        }
    },

    appendArrivalResults: function(toSet, arrivalResults){
        if (arrivalResults && arrivalResults.length){
            var text = '';
            var row = arrivalResults[0];
            var date = row.date;
            if (date) {
                date = LDK.ConvertUtils.parseDate(row.date);
                text = date ? date.format(LABKEY.extDefaultDateFormat) : null;
            }
            var source = row.source;
            if (source) {
                if (text !== '')
                    text += "&nbsp" + LABKEY.Utils.encodeHtml(source);
                else
                    text = LABKEY.Utils.encodeHtml(source);
            }
            if (text !== '')
                toSet['acquisition'] = text;

            var previousId = row.arrivalId;
            if (previousId)
                toSet['previousId'] = LABKEY.Utils.encodeHtml(previousId);
        }
    },

    appendDeath: function(toSet, deathResults){
        if (deathResults && deathResults.length){
            var text = '';
            var row = deathResults[0];
            var date = row.date;
            if (date) {
                date = LDK.ConvertUtils.parseDate(row.date);
                text = date ? date.format(LABKEY.extDefaultDateFormat) : null;
            }
            var manner = row.manner;
            if (manner) {
                if (text !== '')
                    text += "&nbsp&nbsp" + LABKEY.Utils.encodeHtml(manner);
                else
                    text = LABKEY.Utils.encodeHtml(manner);
            }
            var cause = row.cause;
            if (cause) {
                if (text !== '')
                    text += "&nbsp&nbsp" + LABKEY.Utils.encodeHtml(cause);
                else
                    text = LABKEY.Utils.encodeHtml(cause);
            }

            if (text !== '')
                toSet['death'] = text;
        }
    },

    appendDeparture: function(toSet, results){
        if (results.getMostRecentDeparture()) {
            var date = LDK.ConvertUtils.parseDate(results.getMostRecentDeparture());
            toSet['departure'] = date.format(LABKEY.extDefaultDateFormat) + '&nbsp&nbsp' + LABKEY.Utils.encodeHtml(results.getMostRecentDepartureDestination());
        }
    },

    appendLocation: function(toSet, results){
        var location;

        var status = results.getCalculatedStatus();
        if (status) {
            if (status === 'Shipped')
                location = 'SHIPPED';
            else if (status === 'Dead') {
                location = 'DEAD from'
            }
        }

        var lastLocationRows = results.getLocationRows();

        if (lastLocationRows) {
            var lastLocationRow = lastLocationRows[0];
            if (lastLocationRow) {
                if (lastLocationRow['date']) {
                    var date = LDK.ConvertUtils.parseDate(lastLocationRow['date']);
                    if (location)
                        location = date.format(LABKEY.extDefaultDateFormat) + '&nbsp&nbsp' + location;
                    else
                        location = date.format(LABKEY.extDefaultDateFormat);
                }
                if (lastLocationRow['Location']) {
                    if (status && status === 'Shipped')
                        ; // do nothing
                    else if (location)
                        location += '&nbsp' + LABKEY.Utils.encodeHtml(lastLocationRow['Location']);
                    else
                        location = LABKEY.Utils.encodeHtml(lastLocationRow['Location']);
                }
            }
        }
        if (location)
            toSet['location'] = location;
    },

    appendWeight: function(toSet, results){
        if (results.getMostRecentWeightDate()) {
            var date = LDK.ConvertUtils.parseDate(results.getMostRecentWeightDate());
            var weight = date.format(LABKEY.extDefaultDateFormat);
            weight += '&nbsp&nbsp' + Number(Math.round(LABKEY.Utils.encodeHtml(results.getMostRecentWeight())+'e2')+'e-2').toFixed(2) + ' kg';  // always show two decimal places
            toSet['weight'] = weight;
        }
    },

    appendBCS: function(toSet, results){
        if (results.getMostRecentBCS()) {
            var date = LDK.ConvertUtils.parseDate(results.getMostRecentBCSDate());
            toSet['bodyCondition'] = date.format(LABKEY.extDefaultDateFormat) + '&nbsp&nbsp' + LABKEY.Utils.encodeHtml(results.getMostRecentBCS());
        }
    },

    appendTBResults: function(toSet, results){
        if (results.getLastTBDate()) {
            var date = LDK.ConvertUtils.parseDate(results.getLastTBDate());
            toSet['tbTest'] = date.format(LABKEY.extDefaultDateFormat);
        }
    },

    appendSerumBank: function(toSet, results){
        if (results.getMostRecentSerumDate()) {
            var date = LDK.ConvertUtils.parseDate(results.getMostRecentSerumDate());
            toSet['serumBank'] = date.format(LABKEY.extDefaultDateFormat);
        }
    },

    appendHarvestDate: function(toSet, results){
        if (results.getHarvestDate()) {
            var date = LDK.ConvertUtils.parseDate(results.getHarvestDate());
            toSet['harvest'] = date.format(LABKEY.extDefaultDateFormat);
        }
    },

    appendSPFStatus: function(toSet, results){
        if (results.getSPFName())
            toSet['spfStatus'] = LABKEY.Utils.encodeHtml(results.getSPFName());
    },

    appendColony: function(toSet, results){
        if (results.getColony())
            toSet['colony'] = LABKEY.Utils.encodeHtml(results.getColony());
    },

    appendBreedingGroup: function(toSet, results){
        if (results.getBreedingGroup())
            toSet['breedingGroup'] = LABKEY.Utils.encodeHtml(results.getBreedingGroup());
    },

    appendPerDiem: function(toSet, results){
        if (results.getLastPayorDate()) {
            var date = LDK.ConvertUtils.parseDate(results.getLastPayorDate());
            toSet['perdiem'] = date.format(LABKEY.extDefaultDateFormat) + '&nbsp&nbsp' + LABKEY.Utils.encodeHtml(results.getLastPayorId());
        }
    },

    appendHousingIntervals: function(toSet, results){
        if (results.getAgeToday())
            toSet['ageToday'] = LABKEY.Utils.encodeHtml(results.getAgeToday());
        if (results.getAcquisitionAge())
            toSet['acquisitionAge'] = LABKEY.Utils.encodeHtml(results.getAcquisitionAge());
        if (results.getTimeAtCnprc())
            toSet['timeAtCnprc'] = LABKEY.Utils.encodeHtml(results.getTimeAtCnprc());
        if (results.getAgeAtDeparture())
            toSet['ageAtDeparture'] = LABKEY.Utils.encodeHtml(results.getAgeAtDeparture());
    },

    appendLastProjects: function(toSet, rows){
        var values = [];
        if (rows){
            Ext4.each(rows, function(row){
                var val = '';
                if (row['projectDate']) {
                    var date = LDK.ConvertUtils.parseDate(row['projectDate']);
                    val += date.format(LABKEY.extDefaultDateFormat);
                }
                if (row['projectType'])
                    val += '&nbsp&nbsp' + LABKEY.Utils.encodeHtml(row['projectType']);
                if (row['projectId'])
                    val += '&nbsp&nbsp<a href="cnprc_ehr-projectDetails.view?project=' + LABKEY.Utils.encodeHtml(row['projectId']) + '">' + LABKEY.Utils.encodeHtml(row['projectId']) + "</a>";
                if (row['pi'])
                    val += '&nbsp&nbsp' + LABKEY.Utils.encodeHtml(row['pi']);
                if (row['projectName'])
                    val += '&nbsp&nbsp' + LABKEY.Utils.encodeHtml(row['projectName']);

                var text = val;

                if (text !== '') {
                    text = '<span>' + text + '</span>';
                    values.push(text);
                }
            }, this);
        }

        toSet['lastProjects'] = values.length ? values.join('<br>') + '</div>' : null;
    },

    appendCensusFlags: function(toSet, rows){
        var values = [];
        if (rows){
            Ext4.each(rows, function(row){
                var item = '';
                if (row['Value'])
                    item += '<td nowrap><a href="study-dataset.view?datasetId=5019&Dataset.enddate~isblank&Dataset.flag~eq=' + LABKEY.Utils.encodeHtml(row['Value']) + '">' + LABKEY.Utils.encodeHtml(row['Value']) + "</a></td>";
                else
                    item += '<td></td>';
                if (row['Title'])
                    item += '<td nowrap style="padding-left: 10px;">' + LABKEY.Utils.encodeHtml(row['Title']) + '</td>';
                else
                    item += '<td></td>';

                var text = item;

                text = '<tr>' + text + '</tr>';
                values.push(text);
            }, this);

            if (values.length) {
                values = Ext4.unique(values);
            }
        }

        toSet['censusFlags'] = values.length ? '<table>' + values.join('') + '</table>' : null;
    },

    appendPathologyReports: function(toSet, rows){
        var values = '';
        var headerColStyle = 'nowrap style="padding-left: 10px; font-weight: bold"';
        var colStyle = 'nowrap style="padding-left: 10px;"';
        values += '<table><tr><td nowrap style="font-weight: bold">Report ID</td><td ' + headerColStyle + '>Date Performed</td><td ' + headerColStyle + '>Project</td><td ' + headerColStyle + '>Investigator</td><td ' + headerColStyle + '>Date Completed</td></strong></tr>';
        if (rows){
            Ext4.each(rows, function(row){
                var item = '';

                if (row['reportId'])
                    item += '<td nowrap>' + LABKEY.Utils.encodeHtml(row['reportId']) + '</td>';  // TODO: make this into a link like projectId above when Pathology Report Detailed View is implemented
                else
                    item += '<td></td>';
                if (row['datePerformed']) {
                    var datePerformed = LDK.ConvertUtils.parseDate(row['datePerformed']);
                    item += '<td ' + colStyle + '>' + datePerformed.format(LABKEY.extDefaultDateFormat) + '</td>';
                }
                else
                    item += '<td></td>';
                if (row['project'])
                    item += '<td ' + colStyle +'><a href="cnprc_ehr-projectDetails.view?project=' + LABKEY.Utils.encodeHtml(row['project']) + '">' + LABKEY.Utils.encodeHtml(row['project']) + '</a></td>';
                else
                    item += '<td></td>';
                if (row['investigator'])
                    item += '<td ' + colStyle +'>' + LABKEY.Utils.encodeHtml(row['investigator']) + '</td>';
                else
                    item += '<td></td>';
                if (row['dateCompleted']) {
                    var dateCompleted = LDK.ConvertUtils.parseDate(row['dateCompleted']);
                    item += '<td ' + colStyle + '>' + dateCompleted.format(LABKEY.extDefaultDateFormat) + '</td>';
                }
                else
                    item += '<td></td>';

                item = '<tr>' + item + '</tr>';
                values += item;
            }, this);

            values += '</table>';
        }

        toSet['pathologyReports'] = values;
    }
});