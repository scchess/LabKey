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
package org.labkey.mpower.model;

import org.labkey.api.data.Entity;

/**
 * Created by klum on 8/12/2015.
 */
public class FamilyHistory extends Entity
{
    private int _rowId;
    private String _patientId;
    private Integer _relationship;
    private Integer _ageAtDiagnosis;
    private Integer _cancerStartLocation;
    private String  _otherRelationship;

    public FamilyHistory(){}
    public FamilyHistory(String patientId, int relationship, int ageAtDiagnosis)
    {
        _patientId = patientId;
        _relationship = relationship;
        _ageAtDiagnosis = ageAtDiagnosis;
    }

    public int getRowId()
    {
        return _rowId;
    }

    public void setRowId(int rowId)
    {
        _rowId = rowId;
    }

    public String getPatientId()
    {
        return _patientId;
    }

    public void setPatientId(String patientId)
    {
        _patientId = patientId;
    }

    public Integer getRelationship()
    {
        return _relationship;
    }

    public void setRelationship(Integer relationship)
    {
        _relationship = relationship;
    }

    public Integer getAgeAtDiagnosis()
    {
        return _ageAtDiagnosis;
    }

    public void setAgeAtDiagnosis(Integer ageAtDiagnosis)
    {
        _ageAtDiagnosis = ageAtDiagnosis;
    }

    public Integer getCancerStartLocation()
    {
        return _cancerStartLocation;
    }

    public void setCancerStartLocation(Integer cancerStartLocation)
    {
        _cancerStartLocation = cancerStartLocation;
    }

    public String getOtherRelationship()
    {
        return _otherRelationship;
    }

    public void setOtherRelationship(String otherRelationship)
    {
        _otherRelationship = otherRelationship;
    }
}
