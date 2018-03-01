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
import org.labkey.test.components.SideWebPart;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CaseSummaryReport extends SideWebPart
{
    private static final String webPartTitle = "Case Summary Report";
    private final WebElement summaryTable;

    public CaseSummaryReport(WebDriver driver)
    {
        super(driver, webPartTitle);
        summaryTable = getWrapper().waitForElement(Locator.id("summaryTbl").withText());
    }

    public Map<String, Integer> getSummaryTable()
    {
        Map<String, Integer> summary = new HashMap<>();
        List<String> summaryRows = Arrays.asList(summaryTable.getText().split("\n"));
        for (String summaryRow : summaryRows)
        {
            int i = summaryRow.lastIndexOf(" ");
            String key = summaryRow.substring(0, i).trim();
            String valString = summaryRow.substring(i).trim();
            if ("null".equals(valString))
                summary.put(key, null);
            else
                summary.put(key, Integer.parseInt(valString));
        }

        return summary;
    }
}
