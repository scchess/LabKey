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
public class MedicalCondition extends Entity
{
    private int _rowId;
    private String _patientId;

    private String _condition;
    private String _notes;
    private boolean _cancer;

    public MedicalCondition(){}
    public MedicalCondition(String patientId, String condition)
    {
        _patientId = patientId;
        _condition = condition;
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

    public String getCondition()
    {
        return _condition;
    }

    public void setCondition(String condition)
    {
        _condition = condition;
    }

    public String getNotes()
    {
        return _notes;
    }

    public void setNotes(String notes)
    {
        _notes = notes;
    }

    public boolean isCancer()
    {
        return _cancer;
    }

    public void setCancer(boolean cancer)
    {
        _cancer = cancer;
    }
}
