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
package org.labkey.wnprc_ehr.dataentry.Clinpath;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.wnprc_ehr.WNPRCConstants;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.BacteriologyResultsSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.ChemistryResultsSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.ClinpathRunsFormSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.CytologyAutomatedSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.CytologyManualSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.HematologyMorphologySection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.HematologyResultsSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.ImmunologyResultsSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.ParasitologyResultsSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.UrinalysisResultsSection;
import org.labkey.wnprc_ehr.dataentry.Clinpath.FormSections.VirologyResultsSection;

import java.util.Arrays;

public class ClinpathForm extends TaskForm {
    public static final String NAME = "Clinpath";

    public ClinpathForm(DataEntryFormContext ctx, Module owner) {
        super(ctx, owner, NAME, "Enter " + NAME + " Results", WNPRCConstants.DataEntrySections.PATHOLOGY_CLINPATH, Arrays.asList(
                new TaskFormSection(),
                new ClinpathRunsFormSection(),
                new AnimalDetailsFormSection(),
                new BacteriologyResultsSection(),
                new ChemistryResultsSection(),
                new HematologyResultsSection(),
                new HematologyMorphologySection(),
                new ImmunologyResultsSection(),
                new ParasitologyResultsSection(),
                new UrinalysisResultsSection(),
                new VirologyResultsSection(),
                new CytologyAutomatedSection(),
                new CytologyManualSection()
        ));

        addClientDependency(ClientDependency.fromPath("wnprc_ehr/model/sources/Assay.js"));
    }
}
