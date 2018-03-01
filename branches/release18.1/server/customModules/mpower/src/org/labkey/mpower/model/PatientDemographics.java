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
public class PatientDemographics extends Entity
{
    private String _patientId;
    private Integer _diagnosisStatus;
    private Date _birthDate;
    private boolean _raceWhite;
    private boolean _raceBlack;
    private boolean _raceNativeAmerican;
    private boolean _raceAsian;
    private boolean _raceHawaiian;
    private boolean _raceOther;
    private boolean _raceHispanic;
    private Integer _hispanicOrigin;
    private String _hispanicOriginOther;
    private Integer _zipCode;
    private Integer _educationLevel;
    private Integer _maritalStatus;

    private Integer _employmentStatus;
    private String _employmentStatusOther;

    public String getPatientId()
    {
        return _patientId;
    }

    public void setPatientId(String patientId)
    {
        _patientId = patientId;
    }

    public Integer getDiagnosisStatus()
    {
        return _diagnosisStatus;
    }

    public void setDiagnosisStatus(Integer diagnosisStatus)
    {
        _diagnosisStatus = diagnosisStatus;
    }

    public Date getBirthDate()
    {
        return _birthDate;
    }

    public void setBirthDate(Date birthDate)
    {
        _birthDate = birthDate;
    }

    public boolean isRaceWhite()
    {
        return _raceWhite;
    }

    public void setRaceWhite(boolean raceWhite)
    {
        _raceWhite = raceWhite;
    }

    public boolean isRaceBlack()
    {
        return _raceBlack;
    }

    public void setRaceBlack(boolean raceBlack)
    {
        _raceBlack = raceBlack;
    }

    public boolean isRaceNativeAmerican()
    {
        return _raceNativeAmerican;
    }

    public void setRaceNativeAmerican(boolean raceNativeAmerican)
    {
        _raceNativeAmerican = raceNativeAmerican;
    }

    public boolean isRaceAsian()
    {
        return _raceAsian;
    }

    public void setRaceAsian(boolean raceAsian)
    {
        _raceAsian = raceAsian;
    }

    public boolean isRaceHawaiian()
    {
        return _raceHawaiian;
    }

    public void setRaceHawaiian(boolean raceHawaiian)
    {
        _raceHawaiian = raceHawaiian;
    }

    public boolean isRaceOther()
    {
        return _raceOther;
    }

    public void setRaceOther(boolean raceOther)
    {
        _raceOther = raceOther;
    }

    public boolean isRaceHispanic()
    {
        return _raceHispanic;
    }

    public void setRaceHispanic(boolean raceHispanic)
    {
        _raceHispanic = raceHispanic;
    }

    public Integer getHispanicOrigin()
    {
        return _hispanicOrigin;
    }

    public void setHispanicOrigin(Integer hispanicOrigin)
    {
        _hispanicOrigin = hispanicOrigin;
    }

    public String getHispanicOriginOther()
    {
        return _hispanicOriginOther;
    }

    public void setHispanicOriginOther(String hispanicOriginOther)
    {
        _hispanicOriginOther = hispanicOriginOther;
    }

    public Integer getZipCode()
    {
        return _zipCode;
    }

    public void setZipCode(Integer zipCode)
    {
        _zipCode = zipCode;
    }

    public Integer getEducationLevel()
    {
        return _educationLevel;
    }

    public void setEducationLevel(Integer educationLevel)
    {
        _educationLevel = educationLevel;
    }

    public Integer getMaritalStatus()
    {
        return _maritalStatus;
    }

    public void setMaritalStatus(Integer maritalStatus)
    {
        _maritalStatus = maritalStatus;
    }

    public Integer getEmploymentStatus()
    {
        return _employmentStatus;
    }

    public void setEmploymentStatus(Integer employmentStatus)
    {
        _employmentStatus = employmentStatus;
    }

    public String getEmploymentStatusOther()
    {
        return _employmentStatusOther;
    }

    public void setEmploymentStatusOther(String employmentStatusOther)
    {
        _employmentStatusOther = employmentStatusOther;
    }
}
