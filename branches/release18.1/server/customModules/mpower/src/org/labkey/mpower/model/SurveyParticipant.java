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
package org.labkey.mpower.model;

import org.labkey.api.data.Entity;

import java.util.Date;

/**
 * Created by klum on 6/22/15.
 */
public class SurveyParticipant extends Entity
{
    private int _rowId;
    private String _firstName;
    private String _lastName;
    private String _middleName;
    private String _email;
    private Date _birthDate;
    private String _signature;
    private boolean _arm1Consent;
    private boolean _arm2Consent;
    private boolean _futureResearchConsent;


    public int getRowId()
    {
        return _rowId;
    }

    public void setRowId(int rowId)
    {
        _rowId = rowId;
    }

    public String getFirstName()
    {
        return _firstName;
    }

    public void setFirstName(String firstName)
    {
        _firstName = firstName;
    }

    public String getLastName()
    {
        return _lastName;
    }

    public void setLastName(String lastName)
    {
        _lastName = lastName;
    }

    public String getMiddleName()
    {
        return _middleName;
    }

    public void setMiddleName(String middleName)
    {
        _middleName = middleName;
    }

    public Date getBirthDate()
    {
        return _birthDate;
    }

    public void setBirthDate(Date birthDate)
    {
        _birthDate = birthDate;
    }

    public String getEmail()
    {
        return _email;
    }

    public void setEmail(String email)
    {
        _email = email;
    }

    public String getSignature()
    {
        return _signature;
    }

    public void setSignature(String signature)
    {
        _signature = signature;
    }

    public boolean isArm1Consent()
    {
        return _arm1Consent;
    }

    public void setArm1Consent(boolean arm1Consent)
    {
        _arm1Consent = arm1Consent;
    }

    public boolean isArm2Consent()
    {
        return _arm2Consent;
    }

    public void setArm2Consent(boolean arm2Consent)
    {
        _arm2Consent = arm2Consent;
    }

    public boolean isFutureResearchConsent()
    {
        return _futureResearchConsent;
    }

    public void setFutureResearchConsent(boolean futureResearchConsent)
    {
        _futureResearchConsent = futureResearchConsent;
    }
}
