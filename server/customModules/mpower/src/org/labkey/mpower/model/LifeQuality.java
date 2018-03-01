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
public class LifeQuality extends Entity
{
    private int _rowId;
    private String _patientId;

    private Integer _fourWeekFrequencyUrineLeaking;
    private Integer _fourWeekUrineControl;
    private Integer _fourWeekDiaperUse;
    private Integer _fourWeekProblemUrineLeaking;
    private Integer _fourWeekProblemUrinationPain;
    private Integer _fourWeekProblemUrinationBleeding;
    private Integer _fourWeekProblemUrinationWeakStream;
    private Integer _fourWeekProblemUrinationFrequently;

    private Integer _fourWeekProblemUrinationOverall;
    private Integer _problemBowelUrgency;
    private Integer _problemBowelFrequency;
    private Integer _problemStoolControl;
    private Integer _problemStoolBlood;
    private Integer _problemRectalPain;

    private Integer _fourWeekProblemBowel;
    private Integer _fourWeekAbilityErection;
    private Integer _fourWeekAbilityOrgasm;

    private Integer _fourWeekQualityErection;
    private Integer _fourWeekFrequencyErection;
    private Integer _fourWeekSexualFunction;
    private Integer _fourWeekSexualProblem;
    private Integer _fourWeekProblemHotFlash;
    private Integer _fourWeekProblemBreast;
    private Integer _fourWeekProblemDepression;
    private Integer _fourWeekProblemEnergy;
    private Integer _fourWeekProblemWeight;

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

    public Integer getFourWeekFrequencyUrineLeaking()
    {
        return _fourWeekFrequencyUrineLeaking;
    }

    public void setFourWeekFrequencyUrineLeaking(Integer fourWeekFrequencyUrineLeaking)
    {
        _fourWeekFrequencyUrineLeaking = fourWeekFrequencyUrineLeaking;
    }

    public Integer getFourWeekUrineControl()
    {
        return _fourWeekUrineControl;
    }

    public void setFourWeekUrineControl(Integer fourWeekUrineControl)
    {
        _fourWeekUrineControl = fourWeekUrineControl;
    }

    public Integer getFourWeekDiaperUse()
    {
        return _fourWeekDiaperUse;
    }

    public void setFourWeekDiaperUse(Integer fourWeekDiaperUse)
    {
        _fourWeekDiaperUse = fourWeekDiaperUse;
    }

    public Integer getFourWeekProblemUrineLeaking()
    {
        return _fourWeekProblemUrineLeaking;
    }

    public void setFourWeekProblemUrineLeaking(Integer fourWeekProblemUrineLeaking)
    {
        _fourWeekProblemUrineLeaking = fourWeekProblemUrineLeaking;
    }

    public Integer getFourWeekProblemUrinationPain()
    {
        return _fourWeekProblemUrinationPain;
    }

    public void setFourWeekProblemUrinationPain(Integer fourWeekProblemUrinationPain)
    {
        _fourWeekProblemUrinationPain = fourWeekProblemUrinationPain;
    }

    public Integer getFourWeekProblemUrinationBleeding()
    {
        return _fourWeekProblemUrinationBleeding;
    }

    public void setFourWeekProblemUrinationBleeding(Integer fourWeekProblemUrinationBleeding)
    {
        _fourWeekProblemUrinationBleeding = fourWeekProblemUrinationBleeding;
    }

    public Integer getFourWeekProblemUrinationWeakStream()
    {
        return _fourWeekProblemUrinationWeakStream;
    }

    public void setFourWeekProblemUrinationWeakStream(Integer fourWeekProblemUrinationWeakStream)
    {
        _fourWeekProblemUrinationWeakStream = fourWeekProblemUrinationWeakStream;
    }

    public Integer getFourWeekProblemUrinationFrequently()
    {
        return _fourWeekProblemUrinationFrequently;
    }

    public void setFourWeekProblemUrinationFrequently(Integer fourWeekProblemUrinationFrequently)
    {
        _fourWeekProblemUrinationFrequently = fourWeekProblemUrinationFrequently;
    }

    public Integer getFourWeekProblemUrinationOverall()
    {
        return _fourWeekProblemUrinationOverall;
    }

    public void setFourWeekProblemUrinationOverall(Integer fourWeekProblemUrinationOverall)
    {
        _fourWeekProblemUrinationOverall = fourWeekProblemUrinationOverall;
    }

    public Integer getProblemBowelUrgency()
    {
        return _problemBowelUrgency;
    }

    public void setProblemBowelUrgency(Integer problemBowelUrgency)
    {
        _problemBowelUrgency = problemBowelUrgency;
    }

    public Integer getProblemBowelFrequency()
    {
        return _problemBowelFrequency;
    }

    public void setProblemBowelFrequency(Integer problemBowelFrequency)
    {
        _problemBowelFrequency = problemBowelFrequency;
    }

    public Integer getProblemStoolControl()
    {
        return _problemStoolControl;
    }

    public void setProblemStoolControl(Integer problemStoolControl)
    {
        _problemStoolControl = problemStoolControl;
    }

    public Integer getProblemStoolBlood()
    {
        return _problemStoolBlood;
    }

    public void setProblemStoolBlood(Integer problemStoolBlood)
    {
        _problemStoolBlood = problemStoolBlood;
    }

    public Integer getProblemRectalPain()
    {
        return _problemRectalPain;
    }

    public void setProblemRectalPain(Integer problemRectalPain)
    {
        _problemRectalPain = problemRectalPain;
    }

    public Integer getFourWeekProblemBowel()
    {
        return _fourWeekProblemBowel;
    }

    public void setFourWeekProblemBowel(Integer fourWeekProblemBowel)
    {
        _fourWeekProblemBowel = fourWeekProblemBowel;
    }

    public Integer getFourWeekAbilityErection()
    {
        return _fourWeekAbilityErection;
    }

    public void setFourWeekAbilityErection(Integer fourWeekAbilityErection)
    {
        _fourWeekAbilityErection = fourWeekAbilityErection;
    }

    public Integer getFourWeekAbilityOrgasm()
    {
        return _fourWeekAbilityOrgasm;
    }

    public void setFourWeekAbilityOrgasm(Integer fourWeekAbilityOrgasm)
    {
        _fourWeekAbilityOrgasm = fourWeekAbilityOrgasm;
    }

    public Integer getFourWeekQualityErection()
    {
        return _fourWeekQualityErection;
    }

    public void setFourWeekQualityErection(Integer fourWeekQualityErection)
    {
        _fourWeekQualityErection = fourWeekQualityErection;
    }

    public Integer getFourWeekFrequencyErection()
    {
        return _fourWeekFrequencyErection;
    }

    public void setFourWeekFrequencyErection(Integer fourWeekFrequencyErection)
    {
        _fourWeekFrequencyErection = fourWeekFrequencyErection;
    }

    public Integer getFourWeekSexualFunction()
    {
        return _fourWeekSexualFunction;
    }

    public void setFourWeekSexualFunction(Integer fourWeekSexualFunction)
    {
        _fourWeekSexualFunction = fourWeekSexualFunction;
    }

    public Integer getFourWeekSexualProblem()
    {
        return _fourWeekSexualProblem;
    }

    public void setFourWeekSexualProblem(Integer fourWeekSexualProblem)
    {
        _fourWeekSexualProblem = fourWeekSexualProblem;
    }

    public Integer getFourWeekProblemHotFlash()
    {
        return _fourWeekProblemHotFlash;
    }

    public void setFourWeekProblemHotFlash(Integer fourWeekProblemHotFlash)
    {
        _fourWeekProblemHotFlash = fourWeekProblemHotFlash;
    }

    public Integer getFourWeekProblemBreast()
    {
        return _fourWeekProblemBreast;
    }

    public void setFourWeekProblemBreast(Integer fourWeekProblemBreast)
    {
        _fourWeekProblemBreast = fourWeekProblemBreast;
    }

    public Integer getFourWeekProblemDepression()
    {
        return _fourWeekProblemDepression;
    }

    public void setFourWeekProblemDepression(Integer fourWeekProblemDepression)
    {
        _fourWeekProblemDepression = fourWeekProblemDepression;
    }

    public Integer getFourWeekProblemEnergy()
    {
        return _fourWeekProblemEnergy;
    }

    public void setFourWeekProblemEnergy(Integer fourWeekProblemEnergy)
    {
        _fourWeekProblemEnergy = fourWeekProblemEnergy;
    }

    public Integer getFourWeekProblemWeight()
    {
        return _fourWeekProblemWeight;
    }

    public void setFourWeekProblemWeight(Integer fourWeekProblemWeight)
    {
        _fourWeekProblemWeight = fourWeekProblemWeight;
    }
}
