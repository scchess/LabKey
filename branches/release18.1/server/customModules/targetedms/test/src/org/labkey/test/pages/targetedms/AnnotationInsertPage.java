/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
package org.labkey.test.pages.targetedms;

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.pages.InsertPage;
import org.labkey.test.util.targetedms.QCHelper;
import org.openqa.selenium.WebDriver;

public class AnnotationInsertPage extends InsertPage
{
    private static final String DEFAULT_TITLE = "Insert QCAannotation";

    public AnnotationInsertPage(WebDriver driver)
    {
        super(driver, DEFAULT_TITLE);
    }

    @Override
    protected void waitForReady()
    {
        waitForElement(elements().annotationType);
    }

    public void insert(QCHelper.Annotation annotation)
    {
        Elements elements = elements();
        selectOptionByText(elements.annotationType, annotation.getType());
        setFormElement(elements.description, annotation.getDescription());
        setFormElement(elements.date, annotation.getDate());
        clickAndWait(elements.submit);
    }

    @Override
    protected Elements elements()
    {
        return new Elements();
    }

    private class Elements extends InsertPage.Elements
    {
        public Locator.XPathLocator annotationType = body.append(Locator.tagWithName("select", "quf_QCAnnotationTypeId"));
        public Locator.XPathLocator description = body.append(Locator.tagWithName("textarea", "quf_Description"));
        public Locator.XPathLocator date = body.append(Locator.tagWithName("input", "quf_Date"));
    }
}
