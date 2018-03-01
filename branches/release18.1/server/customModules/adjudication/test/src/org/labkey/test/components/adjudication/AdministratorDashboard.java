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
package org.labkey.test.components.adjudication;

import org.labkey.test.Locator;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.pages.adjudication.AdminReviewAdjudicationsPage;
import org.labkey.test.selenium.LazyWebElement;
import org.labkey.test.util.Ext4Helper;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class AdministratorDashboard extends BodyWebPart
{
    private static final String webPartTitle = "Dashboard";

    private WebElement viewCombo = new LazyWebElement(Ext4Helper.Locators.formItemWithLabel("View:"), this);

    public AdministratorDashboard(WebDriver driver)
    {
        super(driver, webPartTitle);
    }

    public AdminReviewAdjudicationsPage clickCaseDetails(String caseId)
    {
        getWrapper().waitAndClickAndWait(Locator.linkWithHref("adjid=" + caseId + "&").withText("details"));
        return new AdminReviewAdjudicationsPage(getDriver());
    }
}
