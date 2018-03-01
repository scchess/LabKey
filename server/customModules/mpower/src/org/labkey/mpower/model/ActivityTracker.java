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

/**
 * Created by klum on 9/3/2015.
 */
public class ActivityTracker
{
    private String _patientId;
    private String _fitbitUserName;
    private String _fitbitPassword;
    private String _jawboneUserName;
    private String _jawbonePassword;

    public String getPatientId()
    {
        return _patientId;
    }

    public void setPatientId(String patientId)
    {
        _patientId = patientId;
    }

    public String getFitbitUserName()
    {
        return _fitbitUserName;
    }

    public void setFitbitUserName(String fitbitUserName)
    {
        _fitbitUserName = fitbitUserName;
    }

    public String getFitbitPassword()
    {
        return _fitbitPassword;
    }

    public void setFitbitPassword(String fitbitPassword)
    {
        _fitbitPassword = fitbitPassword;
    }

    public String getJawboneUserName()
    {
        return _jawboneUserName;
    }

    public void setJawboneUserName(String jawboneUserName)
    {
        _jawboneUserName = jawboneUserName;
    }

    public String getJawbonePassword()
    {
        return _jawbonePassword;
    }

    public void setJawbonePassword(String jawbonePassword)
    {
        _jawbonePassword = jawbonePassword;
    }

    public boolean isDirty()
    {
        return (_fitbitUserName != null && _fitbitPassword != null) || (_jawboneUserName != null && _jawbonePassword != null);
    }
}
