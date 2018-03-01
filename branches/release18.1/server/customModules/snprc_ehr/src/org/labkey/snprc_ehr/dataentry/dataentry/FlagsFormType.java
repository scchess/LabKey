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

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.security.permissions.Permission;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class FlagsFormType extends UnsaveableTask
{
    public static final String NAME = "flags";

    public FlagsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Attributes", "Colony Management", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "flags", "Flags")
        ));
    }

    @Override
    protected boolean canInsert()
    {
        boolean canInsert = true;
        for (FormSection section : getFormSections())
        {
            for (Class<? extends Permission> clazz : getAvailabilityPermissions())
            {
                if (!section.hasPermission(getCtx(), clazz))
                {
                    canInsert = false;
                    break;
                }
            }
        }

        return canInsert;
    }
}
