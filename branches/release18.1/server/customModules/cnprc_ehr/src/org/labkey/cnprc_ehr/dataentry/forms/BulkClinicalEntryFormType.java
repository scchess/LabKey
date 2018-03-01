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
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.forms.DrugAdministrationFormSection;
import org.labkey.api.ehr.dataentry.forms.TreatmentOrdersFormSection;
import org.labkey.api.ehr.dataentry.forms.WeightFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.cnprc_ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.cnprc_ehr.dataentry.ClinicalObservationsFormSection;
import org.labkey.cnprc_ehr.dataentry.SimpleGridPanel;

import java.util.Arrays;

/**
 * Created by Binal on 9/5/2017.
 */
public class BulkClinicalEntryFormType  extends TaskForm
{
    public static final String NAME = "Bulk Clinical Entry";

    public BulkClinicalEntryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Bulk Clinical Entry", "Clinical", Arrays.asList(

                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "Clinical Remarks", "SOAPs", EHRService.FORM_SECTION_LOCATION.Body),
                new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Body),
                new DrugAdministrationFormSection(),
                new TreatmentOrdersFormSection(),
                new WeightFormSection()
        ));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }
}