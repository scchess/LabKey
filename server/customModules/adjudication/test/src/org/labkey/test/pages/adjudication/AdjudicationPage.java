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
package org.labkey.test.pages.adjudication;

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.WebTestHelper;
import org.labkey.test.pages.LabKeyPage;
import org.labkey.test.util.Maps;
import org.openqa.selenium.WebDriver;

import java.util.HashMap;
import java.util.Map;

public class AdjudicationPage extends LabKeyPage
{
    public AdjudicationPage(WebDriver driver)
    {
        super(driver);
        waitForElement(Locator.tagWithClass("div", "gridOne").withoutText("Loading..."));
    }

    public static AdjudicationPage beginAt(BaseWebDriverTest test)
    {
        return beginAt(test, test.getCurrentContainerPath());
    }

    public static AdjudicationPage beginAt(BaseWebDriverTest test, String containerPath)
    {
        test.beginAt(WebTestHelper.buildURL("project", containerPath, "begin", Maps.of("pageId", "Adjudication")));
        return new AdjudicationPage(test.getDriver());
    }

    public AdjudicationDeterminationPage goToDeterminationsAction()
    {
        return goToDeterminationsAction(null);
    }

    public AdjudicationDeterminationPage goToDeterminationsAction(String caseId)
    {
        Map<String, String> params = new HashMap<>();
        if (caseId != null)
            params.put("adjid", caseId);

        beginAt(WebTestHelper.buildURL("adjudication", getCurrentContainerPath(), "adjudicationDetermination", params));
        return new AdjudicationDeterminationPage(getDriver());
    }
}