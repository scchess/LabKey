/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
package org.labkey.test.components.adjudication;

import org.labkey.test.Locator;
import org.labkey.test.components.ext4.Window;
import org.labkey.test.pages.adjudication.AdminReviewAdjudicationsPage;
import org.labkey.test.selenium.LazyWebElement;
import org.labkey.test.util.Ext4Helper;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class AdjudicationDeterminationForm extends Window
{
    Elements _elements;

    public AdjudicationDeterminationForm(WebDriver driver)
    {
        super("Adjudication Determination Form", driver);
        _elements = new Elements();
    }

    public void setHiv1Status(HivStatus status)
    {
        getWrapper()._ext4Helper.selectComboBoxItem(elements().hiv1StatusCombo, status.toString());
    }
    public void setHiv2Status(HivStatus status)
    {
        getWrapper()._ext4Helper.selectComboBoxItem(elements().hiv2StatusCombo, status.toString());
    }
    public void setDate1(String date)
    {
        getWrapper()._ext4Helper.selectComboBoxItemById("dateInfHiv1-combo", date);
    }
    public void setDate2(String date)
    {
        getWrapper()._ext4Helper.selectComboBoxItemById("dateInfHiv2-combo", date);
    }
    public void setComment1(String comment)
    {
        getWrapper().setFormElement(elements().comment1, comment);
    }
    public void setComment2(String comment)
    {
        getWrapper().setFormElement(elements().comment2, comment);
    }

    public HivStatus getHiv1Status()
    {
        return HivStatus.fromString(getWrapper().getFormElement(elements().hiv1StatusCombo.append("//input")));
    }
    public HivStatus getHiv2Status()
    {
        return HivStatus.fromString(getWrapper().getFormElement(elements().hiv2StatusCombo.append("//input")));
    }
    public String getDate1()
    {
        return getWrapper().getFormElement(elements().diagnosisDate1Combo.append("//input"));
    }
    public String getDate2()
    {
        return getWrapper().getFormElement(elements().diagnosisDate2Combo.append("//input"));
    }
    public String getComment1()
    {
        return getWrapper().getFormElement(elements().comment1);
    }
    public String getComment2()
    {
        return getWrapper().getFormElement(elements().comment2);
    }

    public AdminReviewAdjudicationsPage submit(boolean hasConfirmation)
    {
        if (hasConfirmation)
        {
            clickButton("Submit", 0);
            getWrapper()._ext4Helper.clickWindowButtonAndWait("Confirm Inconclusive Status", "Yes");
        }
        else
        {
            clickButton("Submit");
        }

        return new AdminReviewAdjudicationsPage(getDriver());
    }

    public Failure submitFailure()
    {
        clickButton("Submit", 0);
        return new Failure(getDriver());
    }

    public void cancel()
    {
        clickButton("Cancel", 0);
        waitForClose();
    }

    protected Elements elements()
    {
        return _elements;
    }

    class Elements extends Window.Elements
    {
        Locator.XPathLocator hiv1StatusCombo = Ext4Helper.Locators.formItemWithInputNamed("statusHiv1");
        Locator.XPathLocator diagnosisDate1Combo = Ext4Helper.Locators.formItemWithInputNamed("dateInfHiv1");
        WebElement comment1 = new LazyWebElement(Locator.name("commentHiv1"), this);
        Locator.XPathLocator hiv2StatusCombo = Ext4Helper.Locators.formItemWithInputNamed("statusHiv2");
        Locator.XPathLocator diagnosisDate2Combo = Ext4Helper.Locators.formItemWithInputNamed("dateInfHiv2");
        WebElement comment2 = new LazyWebElement(Locator.name("commentHiv2"), this);
    }

    public enum HivStatus
    {
        YES("Yes"),
        NO("No"),
        INCONCLUSIVE("Final Determination is Inconclusive"),
        FURTHER_TESTING("Further Testing Required");

        String _label;

        HivStatus(String label)
        {
            _label = label;
        }

        @Override
        public String toString()
        {
            return _label;
        }

        public static HivStatus fromString(String label)
        {
            for (HivStatus value : values())
            {
                if (value.toString().equals(label))
                    return value;
            }
            throw new IllegalArgumentException("Unknown status: " + label);
        }
    }

    public class Failure extends Window
    {
        public Failure(WebDriver driver)
        {
            super("Failure", driver);
        }

        public void clickOk()
        {
            clickButton("Ok");
            waitForClose();
        }
    }
}
