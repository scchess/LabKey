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
public class TreatmentType extends Entity
{
    private int _rowId;
    private String _patientId;

    private String _name;
    private Date _startDate;
    private Date _endDate;
    private boolean _surgery;
    private boolean _radiation;
    private boolean _ongoing;

    public TreatmentType(){}
    public TreatmentType(String patientId, String name, Date startDate, Date endDate)
    {
        this(patientId, name);
        _startDate = startDate;
        _endDate = endDate;
    }

    public TreatmentType(String patientId, String name)
    {
        _patientId = patientId;
        _name = name;
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

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        _name = name;
    }

    public Date getStartDate()
    {
        return _startDate;
    }

    public void setStartDate(Date startDate)
    {
        _startDate = startDate;
    }

    public Date getEndDate()
    {
        return _endDate;
    }

    public void setEndDate(Date endDate)
    {
        _endDate = endDate;
    }

    public boolean isSurgery()
    {
        return _surgery;
    }

    public void setSurgery(boolean surgery)
    {
        _surgery = surgery;
    }

    public boolean isRadiation()
    {
        return _radiation;
    }

    public void setRadiation(boolean radiation)
    {
        _radiation = radiation;
    }

    public boolean isOngoing()
    {
        return _ongoing;
    }

    public void setOngoing(boolean ongoing)
    {
        _ongoing = ongoing;
    }
}
