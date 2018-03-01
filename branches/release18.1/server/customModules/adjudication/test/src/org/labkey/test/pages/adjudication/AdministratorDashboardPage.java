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

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.adjudication.AdministratorDashboard;
import org.labkey.test.components.adjudication.CaseSummaryReport;
import org.labkey.test.components.adjudication.Notifications;
import org.labkey.test.pages.LabKeyPage;
import org.labkey.test.util.Maps;

public class AdministratorDashboardPage extends LabKeyPage
{
    public AdministratorDashboardPage(WebDriverWrapper test)
    {
        super(test);
        waitForElement(Locator.tagWithClass("div", "gridOne").withoutText("Loading..."));
        Locators.pageSignal("adjudicationDashboardComplete").waitForElement(test.getDriver(), BaseWebDriverTest.WAIT_FOR_PAGE);
    }

    public static AdministratorDashboardPage beginAt(WebDriverWrapper test)
    {
        return beginAt(test, test.getCurrentContainerPath());
    }

    public static AdministratorDashboardPage beginAt(WebDriverWrapper test, String containerPath)
    {
        test.beginAt(WebTestHelper.buildURL("project", containerPath, "begin", Maps.of("pageId", "AdministratorDashboard")));
        return new AdministratorDashboardPage(test);
    }

    public Notifications getNotificationsWebPart()
    {
        return new Notifications(this);
    }

    public CaseSummaryReport getCaseSummaryWebPart()
    {
        return new CaseSummaryReport(getDriver());
    }

    public AdministratorDashboard getAdministratorDashboardWebPart()
    {
        return new AdministratorDashboard(getDriver());
    }
}