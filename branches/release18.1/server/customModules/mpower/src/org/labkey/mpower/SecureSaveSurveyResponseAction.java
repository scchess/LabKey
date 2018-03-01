/*
 * Copyright (c) 2015 LabKey Corporation
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
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.data.DbScope;
import org.labkey.api.security.ActionNames;
import org.labkey.api.security.CSRF;
import org.labkey.api.security.RequiresPermission;
import org.labkey.mpower.model.ActivityTracker;
import org.labkey.mpower.model.ClinicalDiagnosis;
import org.labkey.mpower.model.FamilyHistory;
import org.labkey.mpower.model.Insurance;
import org.labkey.mpower.model.LifeQuality;
import org.labkey.mpower.model.Lifestyle;
import org.labkey.mpower.model.MedicalCondition;
import org.labkey.mpower.model.PatientDemographics;
import org.labkey.mpower.model.Treatment;
import org.labkey.mpower.model.TreatmentType;
import org.labkey.mpower.security.MPowerSecureSubmitter;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by klum on 8/18/2015.
 */

@RequiresPermission(MPowerSecureSubmitter.class)
@ActionNames("saveSurveyResponse")
@CSRF
public class SecureSaveSurveyResponseAction extends PublicSaveSurveyResponseAction
{
    private PatientDemographics _patientDemographics;
    private ClinicalDiagnosis _clinicalDiagnosis;
    private Treatment _treatment;
    private LifeQuality _lifeQuality;
    private Lifestyle _lifestyle;
    private ActivityTracker _activityTracker;

    private List<Insurance> _insuranceList = new ArrayList<>();
    private List<FamilyHistory> _familyHistoryList = new ArrayList<>();
    private List<TreatmentType> _treatmentTypeList = new ArrayList<>();
    private List<MedicalCondition> _medicalConditionList = new ArrayList<>();

    @Override
    public void validateForm(SurveyResponseForm form, Errors errors)
    {
        MPowerSecureController.validatePermission(getUser(), getContainer(), errors);

        if (StringUtils.isBlank(form.getToken()))
        {
            errors.reject("Token is required");
        }

        if (!errors.hasErrors())
        {
            _patientDemographics = MPowerManager.get().createPatientDemographics(form);
            _clinicalDiagnosis = MPowerManager.get().createClinicalDiagnosis(form);
            _treatment = MPowerManager.get().createTreatment(form);
            _lifeQuality = MPowerManager.get().createLifequality(form);
            _lifestyle = MPowerManager.get().createLifestyle(form);
            _activityTracker = MPowerManager.get().createActivityTracker(form);

            _insuranceList = parseInsuranceInformation(form, errors);
            _familyHistoryList = parseFamilyHistory(form, errors);
            _treatmentTypeList = parseTreatmentTypes(form, errors);
            _medicalConditionList = parseMedicalConditions(form, errors);
        }
    }

    @Override
    public ApiResponse execute(SurveyResponseForm form, BindException errors) throws Exception
    {
        ApiSimpleResponse response = new ApiSimpleResponse();

        try (DbScope.Transaction transaction = MPowerSchema.getInstance().getSchema().getScope().ensureTransaction())
        {
            MPowerManager.get().savePatientDemographics(getUser(), getContainer(), _patientDemographics);

            for (Insurance insurance : _insuranceList)
            {
                MPowerManager.get().savePatientInsurance(getUser(), getContainer(), insurance);
            }

            MPowerManager.get().saveClinicalDiagnosis(getUser(), getContainer(), _clinicalDiagnosis);

            for (FamilyHistory history : _familyHistoryList)
            {
                MPowerManager.get().saveFamilyHistory(getUser(), getContainer(), history);
            }

            MPowerManager.get().saveTreatement(getUser(), getContainer(), _treatment);
            for (TreatmentType type : _treatmentTypeList)
            {
                MPowerManager.get().saveTreatementType(getUser(), getContainer(), type);
            }

            MPowerManager.get().saveLifeQuality(getUser(), getContainer(), _lifeQuality);
            MPowerManager.get().saveLifeStyle(getUser(), getContainer(), _lifestyle);
            MPowerManager.get().saveActivityTracker(getUser(), getContainer(), _activityTracker);

            for (MedicalCondition condition : _medicalConditionList)
            {
                MPowerManager.get().saveMedicalCondition(getUser(), getContainer(), condition);
            }

            transaction.commit();
            response.put("success", true);
        }
        return response;
    }
}
