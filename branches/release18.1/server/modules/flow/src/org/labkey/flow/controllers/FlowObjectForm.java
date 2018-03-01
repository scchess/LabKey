/*
 * Copyright (c) 2012 LabKey Corporation
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

package org.labkey.flow.controllers;

import org.labkey.api.view.ActionURL;
import org.labkey.api.view.ViewForm;
import org.labkey.flow.data.FlowObject;
import org.springframework.web.servlet.mvc.Controller;

/**
 * User: kevink
 * Date: 3/18/12
 */
public class FlowObjectForm<FO extends FlowObject> extends ViewForm
{
    protected FO flowObject;

    public FO getFlowObject()
    {
        return flowObject;
    }

    public ActionURL urlShow()
    {
        return getFlowObject().urlShow();
    }

    public ActionURL urlFor(Class<? extends Controller> actionClass)
    {
        return getFlowObject().urlFor(actionClass);
    }

}
