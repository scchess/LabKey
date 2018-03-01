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

import java.util.Date;

/**
 * Created by klum on 8/12/2015.
 */
public class ClinicalDiagnosis extends Entity
{
    private int _rowId;
    private String _patientId;
    private Date _diagnosisDate;
    private Integer _psaLevel;
    private Integer _cancerExtent;
    private Integer _geneticTest;

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

    public Date getDiagnosisDate()
    {
        return _diagnosisDate;
    }

    public void setDiagnosisDate(Date diagnosisDate)
    {
        _diagnosisDate = diagnosisDate;
    }

    public Integer getPsaLevel()
    {
        return _psaLevel;
    }

    public void setPsaLevel(Integer psaLevel)
    {
        _psaLevel = psaLevel;
    }

    public Integer getCancerExtent()
    {
        return _cancerExtent;
    }

    public void setCancerExtent(Integer cancerExtent)
    {
        _cancerExtent = cancerExtent;
    }

    public Integer getGeneticTest()
    {
        return _geneticTest;
    }

    public void setGeneticTest(Integer geneticTest)
    {
        _geneticTest = geneticTest;
    }
}
