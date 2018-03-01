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
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.components.BodyWebPart;
import org.openqa.selenium.WebElement;

import java.util.List;

public class Notifications extends BodyWebPart
{
    private static final String webPartTitle = "Notifications";

    public Notifications(WebDriverWrapper test)
    {
        super(test.getDriver(), webPartTitle, 0);
    }

    public List<String> getNotifications()
    {
        List<WebElement> notifEls = notificationMessage.findElements(this);
        return getWrapper().getTexts(notifEls);
    }

    public static Locator getCaseNotificationsLocator(String caseId)
    {
        return notification.containing("#" + caseId);
    }

    private static final Locator.XPathLocator notificationList = Locator.id("ui-notifications");
    private static final Locator.XPathLocator notification = notificationList.childTag("li");
    private static final Locator.XPathLocator notificationMessage = notification.childTag("span");
}
