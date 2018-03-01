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
package org.labkey.api.ehr.dataentry.forms;

import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

public class AssignmentFormSection extends SimpleFormSection
{
    public AssignmentFormSection()
    {
        super("study", "assignment", "Assignments","ehr-gridpanel");

        setClientStoreClass("EHR.data.AssignmentClientStore");
        addClientDependency(ClientDependency.fromPath("ehr/data/AssignmentClientStore.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();

        int idx = defaultButtons.indexOf("DELETERECORD");
        assert idx > -1;
        defaultButtons.add(idx+1, "SET_ASSIGNMENT_DEFAULTS");

        return defaultButtons;
    }
}

