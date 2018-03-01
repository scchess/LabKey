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
package org.labkey.test.components;

import org.openqa.selenium.By;
import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * @deprecated Extend {@link org.labkey.test.components.Component.ElementCache} or {@link org.labkey.test.pages.LabKeyPage.ElementCache}
 */
@Deprecated
public abstract class ComponentElements implements SearchContext
{
    protected abstract SearchContext getContext();

    @Override
    public List<WebElement> findElements(By by)
    {
        return getContext().findElements(by);
    }

    @Override
    public WebElement findElement(By by)
    {
        return getContext().findElement(by);
    }
}
