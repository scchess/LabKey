/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
package org.labkey.adjudication.security;

import org.labkey.adjudication.AdjudicationModule;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.security.roles.AbstractModuleScopedRole;

/**
 * Created by davebradlee on 10/30/15.
 *
 */
public class AdjudicationLabPersonnelRole extends AbstractModuleScopedRole
{
    public static final String LAB_PERSONNEL_ROLE_NAME = "Adjudication Lab Personnel";

    public AdjudicationLabPersonnelRole()
    {
        super(
            LAB_PERSONNEL_ROLE_NAME,
            "Adjudication Lab Personnel may upload data and view the Admin Dashboard.",
            AdjudicationModule.class,
            AdjudicationCaseUploadPermission.class, AdjudicationReviewPermission.class, InsertPermission.class, UpdatePermission.class, ReadPermission.class
        );
    }
}
