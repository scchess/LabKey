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
public class Lifestyle extends Entity
{
    private int _rowId;
    private String _patientId;

    private boolean _alternateTherapySpecialDiet;
    private boolean _alternateTherapyDietSupplement;
    private boolean _alternateTherapyVitamin;
    private boolean _alternateTherapyHomeopathy;
    private boolean _alternateTherapyPhysical;
    private boolean _alternateTherapyOriental;
    private boolean _alternateTherapyPsychotherapy;
    private boolean _alternateTherapyPrayer;
    private boolean _alternateTherapyFaith;
    private boolean _alternateTherapyMind;
    private String _alternateTherapyOther;
    private boolean _alternateTherapyNone;

    private boolean _cigarettes;
    private Integer _cigarettesPerDayBeforeDiagnosis;
    private Integer _cigarettesPerDayCurrently;
    private Integer _yearsOfCigaretteUse;

    private boolean _alcohol;
    private Integer _alcoholPerDayBeforeDiagnosis;
    private Integer _alcoholPerDayCurrently;

    private Integer _heightFeet;
    private Integer _heightInches;
    private Integer _weight;
    private Integer _fourWeekDaysOfExercise;
    private Integer _attendedProstateSupportGroup;
    private String _prostateCancerExperience;

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

    public boolean isAlternateTherapySpecialDiet()
    {
        return _alternateTherapySpecialDiet;
    }

    public void setAlternateTherapySpecialDiet(boolean alternateTherapySpecialDiet)
    {
        _alternateTherapySpecialDiet = alternateTherapySpecialDiet;
    }

    public boolean isAlternateTherapyDietSupplement()
    {
        return _alternateTherapyDietSupplement;
    }

    public void setAlternateTherapyDietSupplement(boolean alternateTherapyDietSupplement)
    {
        _alternateTherapyDietSupplement = alternateTherapyDietSupplement;
    }

    public boolean isAlternateTherapyVitamin()
    {
        return _alternateTherapyVitamin;
    }

    public void setAlternateTherapyVitamin(boolean alternateTherapyVitamin)
    {
        _alternateTherapyVitamin = alternateTherapyVitamin;
    }

    public boolean isAlternateTherapyHomeopathy()
    {
        return _alternateTherapyHomeopathy;
    }

    public void setAlternateTherapyHomeopathy(boolean alternateTherapyHomeopathy)
    {
        _alternateTherapyHomeopathy = alternateTherapyHomeopathy;
    }

    public boolean isAlternateTherapyPhysical()
    {
        return _alternateTherapyPhysical;
    }

    public void setAlternateTherapyPhysical(boolean alternateTherapyPhysical)
    {
        _alternateTherapyPhysical = alternateTherapyPhysical;
    }

    public boolean isAlternateTherapyOriental()
    {
        return _alternateTherapyOriental;
    }

    public void setAlternateTherapyOriental(boolean alternateTherapyOriental)
    {
        _alternateTherapyOriental = alternateTherapyOriental;
    }

    public boolean isAlternateTherapyPsychotherapy()
    {
        return _alternateTherapyPsychotherapy;
    }

    public void setAlternateTherapyPsychotherapy(boolean alternateTherapyPsychotherapy)
    {
        _alternateTherapyPsychotherapy = alternateTherapyPsychotherapy;
    }

    public boolean isAlternateTherapyPrayer()
    {
        return _alternateTherapyPrayer;
    }

    public void setAlternateTherapyPrayer(boolean alternateTherapyPrayer)
    {
        _alternateTherapyPrayer = alternateTherapyPrayer;
    }

    public boolean isAlternateTherapyFaith()
    {
        return _alternateTherapyFaith;
    }

    public void setAlternateTherapyFaith(boolean alternateTherapyFaith)
    {
        _alternateTherapyFaith = alternateTherapyFaith;
    }

    public boolean isAlternateTherapyMind()
    {
        return _alternateTherapyMind;
    }

    public void setAlternateTherapyMind(boolean alternateTherapyMind)
    {
        _alternateTherapyMind = alternateTherapyMind;
    }

    public String getAlternateTherapyOther()
    {
        return _alternateTherapyOther;
    }

    public void setAlternateTherapyOther(String alternateTherapyOther)
    {
        _alternateTherapyOther = alternateTherapyOther;
    }

    public boolean isAlternateTherapyNone()
    {
        return _alternateTherapyNone;
    }

    public void setAlternateTherapyNone(boolean alternateTherapyNone)
    {
        _alternateTherapyNone = alternateTherapyNone;
    }

    public boolean isCigarettes()
    {
        return _cigarettes;
    }

    public void setCigarettes(boolean cigarettes)
    {
        _cigarettes = cigarettes;
    }

    public Integer getCigarettesPerDayBeforeDiagnosis()
    {
        return _cigarettesPerDayBeforeDiagnosis;
    }

    public void setCigarettesPerDayBeforeDiagnosis(Integer cigarettesPerDayBeforeDiagnosis)
    {
        _cigarettesPerDayBeforeDiagnosis = cigarettesPerDayBeforeDiagnosis;
    }

    public Integer getCigarettesPerDayCurrently()
    {
        return _cigarettesPerDayCurrently;
    }

    public void setCigarettesPerDayCurrently(Integer cigarettesPerDayCurrently)
    {
        _cigarettesPerDayCurrently = cigarettesPerDayCurrently;
    }

    public Integer getYearsOfCigaretteUse()
    {
        return _yearsOfCigaretteUse;
    }

    public void setYearsOfCigaretteUse(Integer yearsOfCigaretteUse)
    {
        _yearsOfCigaretteUse = yearsOfCigaretteUse;
    }

    public boolean isAlcohol()
    {
        return _alcohol;
    }

    public void setAlcohol(boolean alcohol)
    {
        _alcohol = alcohol;
    }

    public Integer getAlcoholPerDayBeforeDiagnosis()
    {
        return _alcoholPerDayBeforeDiagnosis;
    }

    public void setAlcoholPerDayBeforeDiagnosis(Integer alcoholPerDayBeforeDiagnosis)
    {
        _alcoholPerDayBeforeDiagnosis = alcoholPerDayBeforeDiagnosis;
    }

    public Integer getAlcoholPerDayCurrently()
    {
        return _alcoholPerDayCurrently;
    }

    public void setAlcoholPerDayCurrently(Integer alcoholPerDayCurrently)
    {
        _alcoholPerDayCurrently = alcoholPerDayCurrently;
    }

    public Integer getHeightFeet()
    {
        return _heightFeet;
    }

    public void setHeightFeet(Integer heightFeet)
    {
        _heightFeet = heightFeet;
    }

    public Integer getHeightInches()
    {
        return _heightInches;
    }

    public void setHeightInches(Integer heightInches)
    {
        _heightInches = heightInches;
    }

    public Integer getWeight()
    {
        return _weight;
    }

    public void setWeight(Integer weight)
    {
        _weight = weight;
    }

    public Integer getFourWeekDaysOfExercise()
    {
        return _fourWeekDaysOfExercise;
    }

    public void setFourWeekDaysOfExercise(Integer fourWeekDaysOfExercise)
    {
        _fourWeekDaysOfExercise = fourWeekDaysOfExercise;
    }

    public Integer getAttendedProstateSupportGroup()
    {
        return _attendedProstateSupportGroup;
    }

    public void setAttendedProstateSupportGroup(Integer attendedProstateSupportGroup)
    {
        _attendedProstateSupportGroup = attendedProstateSupportGroup;
    }

    public String getProstateCancerExperience()
    {
        return _prostateCancerExperience;
    }

    public void setProstateCancerExperience(String prostateCancerExperience)
    {
        _prostateCancerExperience = prostateCancerExperience;
    }
}
