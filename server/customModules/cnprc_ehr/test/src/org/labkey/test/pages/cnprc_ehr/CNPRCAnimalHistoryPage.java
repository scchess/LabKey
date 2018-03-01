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

package org.labkey.test.pages.cnprc_ehr;

import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.pages.ehr.AnimalHistoryPage;
import org.openqa.selenium.WebDriver;

public class CNPRCAnimalHistoryPage extends AnimalHistoryPage
{
    public CNPRCAnimalHistoryPage(WebDriver driver)
    {
        super(driver);
    }

    public static CNPRCAnimalHistoryPage beginAt(WebDriverWrapper driverWrapper)
    {
        return beginAt(driverWrapper, driverWrapper.getCurrentContainerPath());
    }

    public static CNPRCAnimalHistoryPage beginAt(WebDriverWrapper driverWrapper, String containerPath)
    {
        driverWrapper.beginAt(WebTestHelper.buildURL("ehr", containerPath, "animalHistory")); // TODO: Change to cnprc_ehr once they have a custom animal history page
        return new CNPRCAnimalHistoryPage(driverWrapper.getDriver());
    }
}
