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
package org.labkey.cnprc_ehr.dataentry;

import org.json.JSONObject;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

public class RoundsRemarksFormSection extends SimpleFormSection
{
    public RoundsRemarksFormSection(String label, EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Remarks", label, "cnprc_ehr-cnprc_roundsremarksgridpanel", location);

        addClientDependency(ClientDependency.fromPath("ehr/plugin/ClinicalObservationsCellEditing.js"));
        addClientDependency(ClientDependency.fromPath("ehr/panel/ClinicalRemarkPanel.js"));
        addClientDependency(ClientDependency.fromPath("ehr/grid/ObservationsRowEditorGridPanel.js"));
        addClientDependency(ClientDependency.fromPath("ehr/plugin/ClinicalRemarksRowEditor.js"));
        addClientDependency(ClientDependency.fromPath("cnprc_ehr/plugin/CNPRC_ClinicalRemarksRowEditor.js"));
        addClientDependency(ClientDependency.fromPath("ehr/data/ClinicalObservationsClientStore.js"));
        addClientDependency(ClientDependency.fromPath("ehr/buttons/roundsButtons.js"));
        addClientDependency(ClientDependency.fromPath("cnprc_ehr/grid/CNPRC_ObservationsRowEditorGridPanel.js"));

        setTemplateMode(TEMPLATE_MODE.NONE);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.remove("COPYFROMSECTION");
        defaultButtons.remove("ADDRECORD");
        defaultButtons.remove("ADDANIMALS");

        if (defaultButtons.contains("DELETERECORD"))
        {
            int idx = defaultButtons.indexOf("DELETERECORD");
            defaultButtons.remove("DELETERECORD");
            defaultButtons.add(idx, "ROUNDSDELETE");
        }

        defaultButtons.add("MARK_ROUNDS_REVIEWED");

        return defaultButtons;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();
        defaultButtons.remove("DUPLICATE");

        return defaultButtons;
    }

    @Override
    public JSONObject toJSON(DataEntryFormContext ctx, boolean includeFormElements)
    {
        JSONObject ret = super.toJSON(ctx, includeFormElements);

        return ret;
    }

    @Override
    protected String getServerSort()
    {
        return "Id/curLocation/room,Id/curLocation/cage,Id";
    }
}