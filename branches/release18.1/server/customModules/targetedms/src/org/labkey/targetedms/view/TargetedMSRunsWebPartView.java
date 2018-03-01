/*
 * Copyright (c) 2014 LabKey Corporation
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
package org.labkey.targetedms.view;

import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.VBox;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartView;
import org.labkey.targetedms.TargetedMSController;
import org.labkey.targetedms.TargetedMSManager;
import org.labkey.targetedms.TargetedMSModule;

/**
 * User: vsharma
 * Date: 1/12/14
 * Time: 4:32 PM
 */
public class TargetedMSRunsWebPartView extends VBox
{
    public TargetedMSRunsWebPartView(ViewContext viewContext)
    {
        TargetedMSModule.FolderType folderType = TargetedMSManager.getFolderType(viewContext.getContainer());
        if(folderType == TargetedMSModule.FolderType.Library || folderType == TargetedMSModule.FolderType.LibraryProtein)
        {
            addView(new JspView("/org/labkey/targetedms/view/conflictSummary.jsp"));
        }
        TargetedMsRunListView runListView = TargetedMsRunListView.createView(viewContext);
        runListView.setFrame(WebPartView.FrameType.NONE);
        this.addView(runListView);

        setFrame(WebPartView.FrameType.PORTAL);
        setTitle(TargetedMSModule.TARGETED_MS_RUNS_WEBPART_NAME);
        setTitleHref(new ActionURL(TargetedMSController.ShowListAction.class, viewContext.getContainer()));
    }
}
