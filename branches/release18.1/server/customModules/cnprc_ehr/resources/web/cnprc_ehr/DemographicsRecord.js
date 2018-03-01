/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('EHR.DemographicsRecord');

EHR.DemographicsRecord = function(data){
    LDK.Assert.assertNotEmpty('cnprc_ehr.DemographicsRecord created without data', data);
    data = data || {};

    return {
        getId: function(){
            return data.Id;
        },

        getProperty: function(prop){
            return data[prop];
        },


        getAgeInDays: function(){
            return data['Id/age/ageInDays'];
        },

        getAgeInYearsAndDays: function(){
            return data['Id/age/yearAndDays'];
        },

        getActiveAnimalGroups: function(){
            return data['activeAnimalGroups'];
        },

        getActiveAssignments: function(){
            return data['activeAssignments'];
        },

        getActiveCases: function(){
            return data['activeCases'];
        },

        getActiveFlags: function(){
            return data['activeFlags'];
        },

        getActiveHousing: function(){
            return data['activeHousing'];
        },

        getCurrentLocation: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                var ret = data['activeHousing'][0].room;
                if (data['activeHousing'][0].cage){
                    ret += '-' + data['activeHousing'][0].cage;
                }

                return ret;
            }
        },

        getCurrentLocationDate: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                return data['activeHousing'][0].date;
            }
        },

        getCurrentRoom: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                return data['activeHousing'][0].room;
            }
        },

        getCurrentCage: function(){
            if (data['activeHousing'] && data['activeHousing'].length){
                return data['activeHousing'][0].cage;
            }
        },

        getActiveProblems: function(){
            return data['activeProblems'];
        },

        getBirth: function(){
            if (data['birth'])
            return LDK.ConvertUtils.parseDate(data['birth']);
        },

        getBirthInfo: function(){
            return data['birthInfo'];
        },

        getDeathInfo: function(){
            return data['deathInfo'];
        },

        getCagemates: function(){
            return data['cagemates'];
        },

        getCalculatedStatus: function(){
            return data['calculated_status'];
        },

        getDam: function(){
            return data['dam'];
        },

        getDaysSinceWeight: function(){
            return data['daysSinceWeight'];
        },

        getDeath: function(){
            if (data['death'])
                return LDK.ConvertUtils.parseDate(data['death']);
        },

        getGenderCode: function(){
            return data['gender'];
        },

        getGender: function(){
            return data['gender/meaning'];
        },

        getGeographicOrigin: function(){
            return data['geographic_origin'];
        },

        getMostRecentWeight: function(){
            return data['mostRecentWeight'];
        },

        getActiveTreatments: function(){
            return data['activeTreatments'];
        },

        getMostRecentWeightDate: function(){
            if (data['mostRecentWeightDate'])
                return LDK.ConvertUtils.parseDate(data['mostRecentWeightDate']);
        },

        getParents: function(){
            return data['parents'];
        },

        getSire: function(){
            return data['sire'];
        },

        getSpecies: function(){
            return data['species'];
        },

        getTBRecord: function(){
            return data['tb'];
        },

        getLastTBDate: function(){
            var date = data['MostRecentTBDate'];

            if (date) {
                return LDK.ConvertUtils.parseDate(date);
            }
        },

        getMonthsUntilTBDue: function(){
            if (data['tb'] && data['tb'].length){
                return data['tb'][0].MonthsUntilDue;
            }
        },

        getMonthsSinceLastTB: function(){
            if (data['tb'] && data['tb'].length){
                return data['tb'][0].MonthsSinceLastTB;
            }
        },

        getRecentWeights: function(){
            return data['weights'];
        },

        getSourceRecord: function(){
            return data.source;
        },

        // Past this point are all data added for CNPRC

        getGenerationNumber: function(){
            return data['genNum'];
        },

        getBirthConceptionNumber: function(){
            return data['conceptionNumber'];
        },

        getDamSpecies: function(){
            return data['damSpecies'];
        },

        getFemaleGeneticsVerify: function(){
            return data['femaleGeneticsVerify'];
        },

        getSireSpecies: function(){
            return data['sireSpecies'];
        },

        getMaleGeneticsVerify: function(){
            return data['maleGeneticsVerify'];
        },

        getArrivalInfo: function(){
            return data['arrivalInfo'];
        },

        getMostRecentDeparture: function(){
            return data['MostRecentDeparture'];
        },

        getMostRecentDepartureDestination: function(){
            return data['MostRecentDepartureDestination'];
        },

        getLocationRows: function(){  // should only ever be one row, though
            return data['lastHousing'];
        },

        getMostRecentBCS: function(){
            return data['BodyConditionScore'];
        },

        getMostRecentBCSDate: function(){
            return data['MostRecentBCSDate'];
        },

        getMostRecentSerumDate: function(){
            return data['MostRecentSerumDate'];
        },

        getHarvestDate: function(){
            return data['harvestDate'];
        },

        getSPFName: function(){
            return data['spf/name'];
        },

        getColony: function(){
            return data['colonyCode'];
        },

        getBreedingGroup: function(){
            return data['groupCode'];
        },

        getLastPayorDate: function(){
            return data['lastPayorDate'];
        },

        getLastPayorId: function(){
            return data['lastPayorId'];
        },

        getAgeToday: function(){
            return data['ageToday'];
        },

        getAcquisitionAge: function(){
            return data['acquisitionAge'];
        },

        getTimeAtCnprc: function(){
            return data['timeAtCnprc'];
        },

        getAgeAtDeparture: function() {
            return data['ageAtDeparture'];
        },

        getLastProjects: function() {
            return data['lastProjects'];
        },

        getCensusFlags: function() {
            return data['activeFlagsSeparated'];
        },

        getPathologyReports: function() {
            return data['pathologyReports'];
        }
    }
}