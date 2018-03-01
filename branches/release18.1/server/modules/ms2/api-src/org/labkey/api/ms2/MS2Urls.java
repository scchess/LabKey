/*
 * Copyright (c) 2008-2015 LabKey Corporation
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
package org.labkey.api.ms2;

import org.labkey.api.action.UrlProvider;
import org.labkey.api.view.ActionURL;
import org.labkey.api.data.Container;

/**
 * UrlProvider interface for the MS2 module
 *
 * User: Dave
 * Date: Jan 21, 2008
 * Time: 9:58:15 AM
 */
public interface MS2Urls extends UrlProvider
{
    public ActionURL getShowPeptideUrl(Container container);

    public ActionURL getShowListUrl(Container container);

    public ActionURL getProteinSearchUrl(Container container);
}
