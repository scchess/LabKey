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
public class Insurance extends Entity
{
    private int _rowId;
    private String _patientId;
    private String _name;
    private boolean _commercial;
    private boolean _military;

    public Insurance(){}
    public Insurance(String patientId, String name)
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

    public boolean isCommercial()
    {
        return _commercial;
    }

    public void setCommercial(boolean commercial)
    {
        _commercial = commercial;
    }

    public boolean isMilitary()
    {
        return _military;
    }

    public void setMilitary(boolean military)
    {
        _military = military;
    }
}
