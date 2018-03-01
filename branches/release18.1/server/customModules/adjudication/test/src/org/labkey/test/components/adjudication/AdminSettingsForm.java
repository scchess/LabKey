/*
 * Copyright (c) 2016 LabKey Corporation
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

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.components.BodyWebPart;
import org.openqa.selenium.WebDriver;

public class AdminSettingsForm extends BodyWebPart
{
    public AdminSettingsForm(WebDriver driver)
    {
        super(driver, "Manage Adjudication");
    }

    public void setFilenamePrefixText(String filePrefix)
    {
        getWrapper()._ext4Helper.selectRadioButton("Text");
        // clicking the "Text" radio button enables the prefixText input field, so wait for it to be enabled
        getWrapper().waitForElementToDisappear(Locator.xpath("//table[contains(@class, 'x4-item-disabled')]//input[@name='prefixText']"));
        getWrapper().setFormElement(Locator.name("prefixText"), filePrefix);
    }

    public void setNumberOfTeams(String numTeams)
    {
        boolean expectLoad = true;
        if (String.valueOf(getNumberOfTeams()).equals(numTeams))
            expectLoad = false;
        getWrapper().doAndWaitForPageToLoad(
                () -> getWrapper()._ext4Helper.selectComboBoxItem("Number of Adjudicator Teams:", numTeams),
                expectLoad ? BaseWebDriverTest.WAIT_FOR_PAGE : 0);
    }

    public int getNumberOfTeams()
    {
        return Integer.parseInt(getWrapper().getFormElement(Locator.name("adjudicatorTeamCount")));
    }

    public void setHivTypesRequired(String hivType)
    {
        getWrapper()._ext4Helper.selectRadioButton(hivType);
    }

    public void save()
    {
        getWrapper().clickAndWait(Locator.tagWithClass("a", "admin-settings-save"));
    }
}
