/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
package org.labkey.study.view.studydesign;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.view.BaseWebPartFactory;
import org.labkey.api.view.JspView;
import org.labkey.api.view.Portal;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartView;

/**
 * User: cnathe
 * Date: 12/27/13
 */
public class VaccineDesignWebpartFactory extends BaseWebPartFactory
{
    public static String NAME = "Vaccine Design";

    public VaccineDesignWebpartFactory()
    {
        super(NAME);
    }

    @Override
    public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
    {
        JspView<Portal.WebPart> view = new JspView<>("/org/labkey/study/view/studydesign/vaccineDesignWebpart.jsp", webPart);
        view.setTitle(NAME);
        view.setFrame(WebPartView.FrameType.PORTAL);
        return view;
    }
}
