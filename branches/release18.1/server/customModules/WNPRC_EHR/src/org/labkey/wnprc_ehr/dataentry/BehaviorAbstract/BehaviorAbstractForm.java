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
package org.labkey.wnprc_ehr.dataentry.BehaviorAbstract;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.wnprc_ehr.WNPRCConstants;
import org.labkey.wnprc_ehr.dataentry.BehaviorAbstract.FormSections.BehaviorAbstractSection;

import java.util.Arrays;

public class BehaviorAbstractForm extends TaskForm {
    public static final String NAME = "Behavior Abstract";

    public BehaviorAbstractForm(DataEntryFormContext ctx, Module owner) {
        super(ctx, owner, NAME, "Enter Behavior Abstract", WNPRCConstants.DataEntrySections.BEHAVIOR_COLONY_MGMT, Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new BehaviorAbstractSection()
        ));

        for(FormSection section: this.getFormSections()) {
            section.addConfigSource("Task");
        }
    }
}
