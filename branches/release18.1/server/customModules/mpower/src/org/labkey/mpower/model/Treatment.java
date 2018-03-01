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
public class Treatment extends Entity
{
    private int _rowId;
    private String _patientId;
    private Integer _currentTreatmentState;
    private boolean _treatmentWithinYear;

    private Integer _primaryClinician;
    private boolean _cancerSpreadBeyondProstate;
    private boolean _spreadToLymphs;
    private boolean _spreadToBones;
    private boolean _spreadToOrgans;
    private String _organsSpreadTo;
    private boolean _spreadToDontKnow;
    private Integer _treatmentSatisfaction;

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

    public Integer getCurrentTreatmentState()
    {
        return _currentTreatmentState;
    }

    public void setCurrentTreatmentState(Integer currentTreatmentState)
    {
        _currentTreatmentState = currentTreatmentState;
    }

    public boolean isTreatmentWithinYear()
    {
        return _treatmentWithinYear;
    }

    public void setTreatmentWithinYear(boolean treatmentWithinYear)
    {
        _treatmentWithinYear = treatmentWithinYear;
    }

    public Integer getPrimaryClinician()
    {
        return _primaryClinician;
    }

    public void setPrimaryClinician(Integer primaryClinician)
    {
        _primaryClinician = primaryClinician;
    }

    public boolean isCancerSpreadBeyondProstate()
    {
        return _cancerSpreadBeyondProstate;
    }

    public void setCancerSpreadBeyondProstate(boolean cancerSpreadBeyondProstate)
    {
        _cancerSpreadBeyondProstate = cancerSpreadBeyondProstate;
    }

    public boolean isSpreadToLymphs()
    {
        return _spreadToLymphs;
    }

    public void setSpreadToLymphs(boolean spreadToLymphs)
    {
        _spreadToLymphs = spreadToLymphs;
    }

    public boolean isSpreadToBones()
    {
        return _spreadToBones;
    }

    public void setSpreadToBones(boolean spreadToBones)
    {
        _spreadToBones = spreadToBones;
    }

    public boolean isSpreadToOrgans()
    {
        return _spreadToOrgans;
    }

    public void setSpreadToOrgans(boolean spreadToOrgans)
    {
        _spreadToOrgans = spreadToOrgans;
    }

    public String getOrgansSpreadTo()
    {
        return _organsSpreadTo;
    }

    public void setOrgansSpreadTo(String organsSpreadTo)
    {
        _organsSpreadTo = organsSpreadTo;
    }

    public boolean isSpreadToDontKnow()
    {
        return _spreadToDontKnow;
    }

    public void setSpreadToDontKnow(boolean spreadToDontKnow)
    {
        _spreadToDontKnow = spreadToDontKnow;
    }

    public Integer getTreatmentSatisfaction()
    {
        return _treatmentSatisfaction;
    }

    public void setTreatmentSatisfaction(Integer treatmentSatisfaction)
    {
        _treatmentSatisfaction = treatmentSatisfaction;
    }
}
