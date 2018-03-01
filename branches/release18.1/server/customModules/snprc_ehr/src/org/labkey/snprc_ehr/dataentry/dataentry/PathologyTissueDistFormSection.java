/*
 * Copyright (c) 2016 LabKey Corporation
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
package org.labkey.snprc_ehr.dataentry.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 11/20/13
 * Time: 7:52 PM
 */
public class PathologyTissueDistFormSection extends EncounterChildFormSection
{
    public PathologyTissueDistFormSection()
    {
        super("study", "tissueDistributions", "Tissue Distributions", false);

        addClientDependency(ClientDependency.fromPath("snprc_ehr/window/CopyTissuesWindow.js"));
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.add("COPY_TISSUES");

        return defaultButtons;
    }
}
