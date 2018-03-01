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
package org.labkey.test.pages.adjudication;

import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.adjudication.AdjudicationDeterminationForm;
import org.labkey.test.pages.LabKeyPage;
import org.labkey.test.selenium.LazyWebElement;
import org.labkey.test.util.Ext4Helper;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdjudicationDeterminationPage extends LabKeyPage<AdjudicationDeterminationPage.ElementCache>
{
    public AdjudicationDeterminationPage(WebDriver driver)
    {
        super(driver);
        if (getDriver().getCurrentUrl().contains("adjid="))
            waitForElement(Locators.pageSignal("determinationTablesLoaded"));
    }

    public static AdjudicationDeterminationPage beginAt(WebDriverWrapper test)
    {
        return beginAt(test, test.getCurrentContainerPath());
    }

    public static AdjudicationDeterminationPage beginAt(WebDriverWrapper test, String containerPath)
    {
        test.beginAt(WebTestHelper.buildURL("adjudication", containerPath, "adjudicationDetermination"));
        return new AdjudicationDeterminationPage(test.getDriver());
    }

    public void waitForCaseVisitRows(int count)
    {
        waitForElements(Locator.tagWithClass("tr", "result-visit-row"), count);
    }

    public void waitForActiveCaseCombo()
    {
        waitForElement(Ext4Helper.Locators.formItemWithLabel("Choose Active Case:"));
    }

    public void selectActiveCaseCombo(String caseId, String status, String ptid)
    {
        waitForActiveCaseCombo();
        String selectionText = "Case ID " + caseId + " (" + status + ")";
        log("Selecting active case from combo: " + selectionText);
        doAndWaitForPageSignal(() -> _ext4Helper.selectComboBoxItem("Choose Active Case:", selectionText), "determinationTablesLoaded", longWait());
        assertElementPresent(Locator.tagWithText("td", ptid));
    }

    public AdjudicationDeterminationForm makeDetermination()
    {
        elementCache().makeDeterminationButton.click();
        return new AdjudicationDeterminationForm(getDriver());
    }

    public AdjudicationDeterminationForm changeDetermination()
    {
        elementCache().changeDeterminationButton.click();
        return new AdjudicationDeterminationForm(getDriver());
    }

    public Map<String, String> getCurrentDeterminationDetails()
    {
        List<WebElement> determinationEls = Locator.css("td:nth-of-type(2) div").findElements(elementCache().completeDeterminationDetails);
        Map<String, String> determinationMap = new HashMap<>();

        for (WebElement determinationEl : determinationEls)
        {
            determinationMap.put(determinationEl.getAttribute("id"), determinationEl.getText());
        }

        return determinationMap;
    }

    @Override
    protected ElementCache newElementCache()
    {
        return new ElementCache();
    }

    protected class ElementCache extends LabKeyPage.ElementCache
    {
        WebElement makeDeterminationButton = new LazyWebElement(Ext4Helper.Locators.ext4Button("Make Determination"), this);
        WebElement changeDeterminationButton = new LazyWebElement(Ext4Helper.Locators.ext4Button("Change Determination"), this);
        WebElement completeDeterminationDetails = new LazyWebElement(Locator.id("compDeterm"), this);
    }
}