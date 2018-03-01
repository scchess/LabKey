/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
package org.labkey.mpower;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpStatus;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.security.ActionNames;
import org.labkey.api.security.CSRF;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.util.DateUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.mpower.model.FamilyHistory;
import org.labkey.mpower.model.Insurance;
import org.labkey.mpower.model.MedicalCondition;
import org.labkey.mpower.model.TreatmentType;
import org.labkey.mpower.remote.SaveSurveyResponseCommand;
import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.Connection;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by klum on 8/18/2015.
 */
@RequiresPermission(ReadPermission.class)
@ActionNames("saveSurveyResponse")
@CSRF
public class PublicSaveSurveyResponseAction extends MutatingApiAction<SurveyResponseForm>
{
    private static final Logger _log = Logger.getLogger(MPowerManager.class);

    @Override
    public void validateForm(SurveyResponseForm form, Errors errors)
    {
        if (StringUtils.isBlank(form.getToken()))
        {
            errors.reject(SpringActionController.ERROR_MSG, "Token is required");
        }

        if (!errors.hasErrors())
        {
            // validate some of the form data
            parseInsuranceInformation(form, errors);
            parseFamilyHistory(form, errors);
            parseTreatmentTypes(form, errors);
            parseMedicalConditions(form, errors);
        }
    }

    @Override
    public ApiResponse execute(SurveyResponseForm form, BindException errors) throws Exception
    {
        ApiSimpleResponse response = new ApiSimpleResponse();
        MPowerManager.RemoteConnectionInfo info = MPowerManager.get().getRemoteConnectionInfo(getContainer());

        if (info != null)
        {
            Connection cn = new Connection(info.getUrl(), info.getUser(), info.getPassword());
            SaveSurveyResponseCommand command = new SaveSurveyResponseCommand(form);
            CommandResponse commandResponse = command.execute(cn, info.getContainer());

            if (commandResponse.getStatusCode() == HttpStatus.SC_OK)
            {
                Map<String, Object> surveyResp = new HashMap<>();

                surveyResp.put("successUrl", new ActionURL("wiki", "page", getContainer()).addParameter("name", "mpowersurveycomplete"));
                response.put("survey", surveyResp);
                response.put("success", true);
            }
        }
        return response;
    }

    protected List<Insurance> parseInsuranceInformation(SurveyResponseForm form, Errors errors)
    {
        List<Insurance> insuranceList = new ArrayList<>();
        Map<String, Object> responses = form.getResponses();
        String commercialInsuranceName = (String)responses.get("coverage_plan_commercial");
        String militaryInsuranceName = (String)responses.get("coverage_plan_military");
        String otherInsuranceName = (String)responses.get("coverage_plan_other");
        JSONArray insuranceCoverage = toArray(responses.get("insurance_coverage"), String.class);

        if (insuranceCoverage != null)
        {
            // iterate over the checkbox selections for each coverage
            for (Object coverage : insuranceCoverage.toArray())
            {
                Insurance insurance = null;
                switch (coverage.toString())
                {
                    case "Commercial":
                        if (commercialInsuranceName != null)
                        {
                            insurance = new Insurance(form.getToken(), commercialInsuranceName);
                            insurance.setCommercial(true);
                        }
                        break;
                    case "Medicare with Supplemental Insurance":
                    case "Medicare without Supplemental Insurance":
                    case "Medicaid":
                        insurance = new Insurance(form.getToken(), coverage.toString());
                        break;
                    case "Military":
                        if (militaryInsuranceName != null)
                        {
                            insurance = new Insurance(form.getToken(), militaryInsuranceName);
                            insurance.setMilitary(true);
                        }
                        break;
                    case "No insurance":
                        break;
                    case "Other":
                        if (otherInsuranceName != null)
                        {
                            insurance = new Insurance(form.getToken(), otherInsuranceName);
                        }
                        break;
                }

                if (insurance != null)
                    insuranceList.add(insurance);
            }
        }
        return insuranceList;
    }

    protected List<FamilyHistory> parseFamilyHistory(SurveyResponseForm form, Errors errors)
    {
        List<FamilyHistory> familyHistoryList = new ArrayList<>();
        Map<String, Object> responses = form.getResponses();

        // parse information for relatives with prostate cancer
        String additionalProstateRelativesRelation = (String)responses.get("additional_relationship_prostate");
        Integer additionalProstateRelativesAge = (Integer)responses.get("additional_age_at_diagnosis_prostate");

        JSONArray prostateRelativesRelation = toArray(responses.get("relatives_with_prostate_cancer"), Integer.class);
        JSONArray prostateRelativesRelationAge = toArray(responses.get("relatives_with_prostate_cancer_age_diagnosis"), Integer.class);

        if (prostateRelativesRelation.length() != prostateRelativesRelationAge.length())
        {
            //errors.reject(SpringActionController.ERROR_MSG, "Information in the Family History of Prostate Cancer section was not filled out completely.");
            _log.warn("Information in the Family History of Prostate Cancer section was not filled out completely.");
        }
        else
        {
            for (int i=0; i < prostateRelativesRelation.length(); i++)
            {
                int relation = prostateRelativesRelation.getInt(i);
                int age = prostateRelativesRelationAge.getInt(i);

                FamilyHistory familyHistory = new FamilyHistory(form.getToken(), relation, age);

                familyHistoryList.add(familyHistory);
            }
        }

        if (additionalProstateRelativesRelation != null && additionalProstateRelativesAge != null)
        {
            FamilyHistory familyHistory = new FamilyHistory();
            familyHistory.setPatientId(form.getToken());
            familyHistory.setOtherRelationship(additionalProstateRelativesRelation);
            familyHistory.setAgeAtDiagnosis(additionalProstateRelativesAge);

            familyHistoryList.add(familyHistory);
        }

        // parse information for relatives with other cancer
        String additionalCancerRelativesRelation = (String)responses.get("additional_relatives_with_other_cancer");
        Integer additionalCancerRelativesAge = (Integer)responses.get("additional_relatives_with_other_cancer_age_diagnosis");
        Integer additionalCancerRelativesLocation = (Integer)responses.get("additional_relatives_with_other_cancer_startlocation");

        JSONArray cancerRelativesRelation = toArray(responses.get("relatives_with_other_cancer"), Integer.class);
        JSONArray cancerRelativesRelationAge = toArray(responses.get("relatives_with_other_cancer_age_diagnosis"), Integer.class);
        JSONArray cancerRelativesRelationLocation = toArray(responses.get("relatives_with_other_cancer_startlocation"), Integer.class);

        if (cancerRelativesRelation.length() != cancerRelativesRelationAge.length() || cancerRelativesRelation.length() != cancerRelativesRelationLocation.length())
        {
            //errors.reject(SpringActionController.ERROR_MSG, "Information in the Family History of Prostate Cancer section was not filled out completely.");
            _log.warn("Information in the Family History of other types of Cancer section was not filled out completely.");
        }
        else
        {
            for (int i=0; i < cancerRelativesRelation.length(); i++)
            {
                int relation = cancerRelativesRelation.getInt(i);
                int age = cancerRelativesRelationAge.getInt(i);
                int location = cancerRelativesRelationLocation.getInt(i);

                FamilyHistory familyHistory = new FamilyHistory(form.getToken(), relation, age);
                familyHistory.setCancerStartLocation(location);

                familyHistoryList.add(familyHistory);
            }
        }

        if (additionalCancerRelativesRelation != null && additionalCancerRelativesAge != null && additionalCancerRelativesLocation != null)
        {
            FamilyHistory familyHistory = new FamilyHistory();
            familyHistory.setPatientId(form.getToken());
            familyHistory.setOtherRelationship(additionalCancerRelativesRelation);
            familyHistory.setAgeAtDiagnosis(additionalCancerRelativesAge);
            familyHistory.setCancerStartLocation(additionalCancerRelativesLocation);

            familyHistoryList.add(familyHistory);
        }
        return familyHistoryList;
    }

    protected List<TreatmentType> parseTreatmentTypes(SurveyResponseForm form, Errors errors)
    {
        List<TreatmentType> treatmentTypeList = new ArrayList<>();
        Map<String, Object> responses = form.getResponses();

        String activeSurvelliance = (String)responses.get("treatment_type_surveillance");

        JSONArray treatmentTypes = toArray(responses.get("treatment_types"), String.class);
        JSONArray treatmentTypesOngoing = toArray(responses.get("treatment_types_ongoing"), String.class);
        JSONArray treatmentTypesBeginDate = toArray(responses.get("treatment_types_begin_date"), String.class);
        JSONArray treatmentTypesEndDate = toArray(responses.get("treatment_types_end_date"), String.class);

        JSONArray treatmentTypesRadiation = toArray(responses.get("treatment_types_radiation"), String.class);
        JSONArray treatmentTypesOngoingRadiation = toArray(responses.get("treatment_types_radiation_ongoing"), String.class);
        JSONArray treatmentTypesRadiationBeginDate = toArray(responses.get("treatment_types_radiation_begin_date"), String.class);
        JSONArray treatmentTypesRadiationEndDate = toArray(responses.get("treatment_types_radiation_end_date"), String.class);

        JSONArray treatmentTypesSurgery = toArray(responses.get("treatment_types_surgery"), String.class);
        JSONArray treatmentTypesSurgeryBeginDate = toArray(responses.get("treatment_types_surgery_date"), String.class);

        if (activeSurvelliance != null)
        {
            TreatmentType type = new TreatmentType();
            type.setPatientId(form.getToken());
            type.setName(activeSurvelliance);

            treatmentTypeList.add(type);
        }

        Set<String> ongoingTreatmentSet = createOngoingTreatmentSet(treatmentTypesOngoing);
        Map<String, Date> beginDateMap = createDateMap(treatmentTypesBeginDate);
        Map<String, Date> endDateMap = createDateMap(treatmentTypesEndDate);
        // validate and add the treatment types
        addTreatmentTypes(form.getToken(), treatmentTypes, ongoingTreatmentSet, beginDateMap, endDateMap, treatmentTypeList, false, false, errors);

        Set<String> ongoingTreatmentRadiationSet = createOngoingTreatmentSet(treatmentTypesOngoingRadiation);
        Map<String, Date> beginRadiationDateMap = createDateMap(treatmentTypesRadiationBeginDate);
        Map<String, Date> endRadiationDateMap = createDateMap(treatmentTypesRadiationEndDate);
        // validate and add the radiation treatment types
        addTreatmentTypes(form.getToken(), treatmentTypesRadiation, ongoingTreatmentRadiationSet, beginRadiationDateMap, endRadiationDateMap, treatmentTypeList, true, false, errors);

        Map<String, Date> surgeryDateMap = createDateMap(treatmentTypesSurgeryBeginDate);
        // validate and add the surgery treatment types
        addTreatmentTypes(form.getToken(), treatmentTypesSurgery, null, surgeryDateMap, null, treatmentTypeList, false, true, errors);

        return treatmentTypeList;
    }

    private boolean validateTreatmentType(String type, @Nullable Set<String> ongoingSet, Map<String, Date> beginDateMap, @Nullable Map<String, Date> endDateMap, Errors errors)
    {
        boolean valid = true;
        if (!(ongoingSet == null) && ongoingSet.contains(type))
        {
            if (!beginDateMap.containsKey(type))
            {
                valid = false;
                //errors.reject(SpringActionController.ERROR_MSG, "Information in the Treatment section was not filled out completely. If treatment is ongoing, begin date must still be provided.");
                _log.warn("Information in the Treatment section was not filled out completely. If treatment is ongoing, begin date must still be provided. The response will be ignored");
            }
        }
        else
        {
            if (!beginDateMap.containsKey(type) || (endDateMap != null && !endDateMap.containsKey(type)))
            {
                valid = false;
                //errors.reject(SpringActionController.ERROR_MSG, "Information in the Treatment section was not filled out completely.");
                _log.warn("Information in the Treatment section was not filled out completely. If treatment is not ongoing, begin and end dates must be provided. The response will be ignored");
            }
        }
        return valid;
    }

    private Set<String> createOngoingTreatmentSet(JSONArray ongoing)
    {
        Set<String> ongoingSet = new HashSet<>();
        for (int i=0; i < ongoing.length(); i++)
        {
            if (!ongoing.isNull(i))
                ongoingSet.add(ongoing.getString(i));
        }
        return ongoingSet;
    }

    /**
     * Parse the json array to create the date map of treatment type to date. Each entry in the json date array
     * has a prefix with the treatment type name and a delimiter of ':'
     */
    private Map<String, Date> createDateMap(JSONArray dateArray)
    {
        Map<String, Date> dateMap = new HashMap<>();
        for (int i=0; i < dateArray.length(); i++)
        {
            if (!dateArray.isNull(i))
            {
                String dateStr = dateArray.getString(i);
                String[] parts = dateStr.split(":");

                if (parts.length == 2)
                    dateMap.put(parts[0], new Date(DateUtil.parseDateTime(getContainer(), parts[1])));
            }
        }
        return dateMap;
    }

    private void addTreatmentTypes(String token, JSONArray treatmentTypes, @Nullable  Set<String> ongoingTreatmentSet, Map<String, Date> beginDateMap,
                                   @Nullable  Map<String, Date> endDateMap, List<TreatmentType> treatmentTypeList, boolean radiation, boolean surgery, Errors errors)
    {
        for (int i=0; i < treatmentTypes.length(); i++)
        {
            if (!treatmentTypes.isNull(i))
            {
                String treatment = treatmentTypes.getString(i);
                if (validateTreatmentType(treatment, ongoingTreatmentSet, beginDateMap, endDateMap, errors))
                {
                    TreatmentType type = new TreatmentType(token, treatment);

                    if (beginDateMap.containsKey(treatment))
                        type.setStartDate(beginDateMap.get(treatment));

                    if (endDateMap != null && endDateMap.containsKey(treatment))
                        type.setEndDate(endDateMap.get(treatment));

                    if (ongoingTreatmentSet != null && ongoingTreatmentSet.contains(treatment))
                        type.setOngoing(true);

                    if (radiation)
                        type.setRadiation(true);

                    if (surgery)
                        type.setSurgery(true);

                    treatmentTypeList.add(type);
                }
            }
        }
    }

    protected List<MedicalCondition> parseMedicalConditions(SurveyResponseForm form, Errors errors)
    {
        List<MedicalCondition> medicalConditionList = new ArrayList<>();
        Map<String, Object> responses = form.getResponses();

        JSONArray healthConditions = toArray(responses.get("prior_health_conditions"), String.class);
        JSONArray healthConditionsCancer = toArray(responses.get("prior_health_conditions_cancer"), String.class);

        String healthConditionOther = (String)responses.get("prior_health_conditions_other");
        String healthConditionOtherNote = (String)responses.get("prior_health_conditions_other_note");

        String healthConditionCancerOther = (String)responses.get("prior_health_cancer_other");
        String healthConditionCancerOtherNote = (String)responses.get("prior_health_cancer_other_note");

        String healthConditionTumorOther = (String)responses.get("prior_health_cancer_tumor");
        String healthConditionTumorOtherNote = (String)responses.get("prior_health_cancer_tumor_note");

        if (healthConditions != null)
        {
            for (int i=0; i < healthConditions.length(); i++)
            {
                MedicalCondition condition = new MedicalCondition(form.getToken(), healthConditions.getString(i));
                medicalConditionList.add(condition);
            }
        }

        if (healthConditionsCancer != null)
        {
            for (int i=0; i < healthConditionsCancer.length(); i++)
            {
                MedicalCondition condition = new MedicalCondition(form.getToken(), healthConditionsCancer.getString(i));
                condition.setCancer(true);
                medicalConditionList.add(condition);
            }
        }

        if (healthConditionOther != null && healthConditionOtherNote != null)
        {
            MedicalCondition condition = new MedicalCondition(form.getToken(), healthConditionOther);
            condition.setNotes(healthConditionOtherNote);
            medicalConditionList.add(condition);
        }

        if (healthConditionCancerOther != null && healthConditionCancerOtherNote != null)
        {
            MedicalCondition condition = new MedicalCondition(form.getToken(), healthConditionCancerOther);
            condition.setCancer(true);
            condition.setNotes(healthConditionCancerOtherNote);
            medicalConditionList.add(condition);
        }

        if (healthConditionTumorOther != null && healthConditionTumorOtherNote != null)
        {
            MedicalCondition condition = new MedicalCondition(form.getToken(), healthConditionTumorOther);
            condition.setCancer(true);
            condition.setNotes(healthConditionTumorOtherNote);
            medicalConditionList.add(condition);
        }
        return medicalConditionList;
    }

    /**
     * Ensures a json array with the specified type
     */
    protected JSONArray toArray(Object o, Class type)
    {
        if (o instanceof JSONArray)
        {
            return (JSONArray)o;
        }
        else if (o != null && o.getClass().equals(type))
        {
            JSONArray arr = new JSONArray();

            if (type.equals(Integer.class))
                arr.put(o);
            else if (type.equals(String.class))
                arr.put(o);

            return arr;
        }
        return new JSONArray();
    }
}
