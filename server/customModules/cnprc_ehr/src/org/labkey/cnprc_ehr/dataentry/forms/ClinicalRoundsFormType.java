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
package org.labkey.cnprc_ehr.dataentry.forms;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.query.Queryable;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.cnprc_ehr.dataentry.AnimalDetailsRoundsFormSection;
import org.labkey.cnprc_ehr.dataentry.ClinicalObservationsFormSection;
import org.labkey.cnprc_ehr.dataentry.ClinicalRoundsRemarksFormSection;
import org.labkey.api.ehr.dataentry.forms.DrugAdministrationFormSection;
import org.labkey.api.ehr.dataentry.forms.TreatmentOrdersFormSection;

import java.util.Arrays;

public class ClinicalRoundsFormType extends TaskForm
{
    @Queryable
    public static final String NAME = "Clinical Rounds";

    public ClinicalRoundsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Clinical", Arrays.asList(
            new TaskFormSection(),
            new AnimalDetailsRoundsFormSection(),
            new ClinicalRoundsRemarksFormSection(),
            new DrugAdministrationFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
            new TreatmentOrdersFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
            new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Tabs, false)
        ));

        setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NONE);

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalDefaults");
            s.addConfigSource("ClinicalRounds");
            s.setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NONE);
            s.addConfigSource("TreatmentOrder");
            s.addConfigSource("ClinicalRemarks");
        }
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalRounds.js"));
        addClientDependency(ClientDependency.fromPath("cnprc_ehr/model/sources/ClinicalRemarks.js"));
        addClientDependency(ClientDependency.fromPath("cnprc_ehr/model/sources/TreatmentOrder.js"));
        addClientDependency(ClientDependency.fromPath("cnprc_ehr/form/field/ProjectCodeField.js"));
        addClientDependency(ClientDependency.fromPath("cnprc_ehr/form/field/ProjectCodeEntryField.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }
}