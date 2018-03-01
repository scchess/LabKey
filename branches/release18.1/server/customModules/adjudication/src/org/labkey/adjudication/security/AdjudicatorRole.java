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
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.roles.AbstractModuleScopedRole;

/**
 * Created by davebradlee on 10/25/15.
 *
 */
public class AdjudicatorRole extends AbstractModuleScopedRole
{
    public static final String ADJUDICATOR_ROLE_NAME = "Adjudicator";

    public AdjudicatorRole()
    {
        super(
            ADJUDICATOR_ROLE_NAME,
            "Adjudicators may make determinations, but may not upload data or view the Admin Dashboard.",
            AdjudicationModule.class,
            AdjudicationPermission.class, ReadPermission.class
        );
    }
}
