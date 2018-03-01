/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.labkey.snprc_ehr.views;

import org.apache.log4j.Logger;
import org.labkey.api.view.JspView;

public class AnimalsHierarchyWebPart extends JspView
{
    private static final Logger _log = Logger.getLogger(AnimalsHierarchyWebPart.class);

    public AnimalsHierarchyWebPart()
    {
        super("/org/labkey/snprc_ehr/views/AnimalsHierarchy.jsp", null);

        setTitle("Animal Tree View Navigation");

    }
}
