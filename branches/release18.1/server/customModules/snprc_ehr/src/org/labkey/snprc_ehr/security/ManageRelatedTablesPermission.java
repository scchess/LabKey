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
package org.labkey.snprc_ehr.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class ManageRelatedTablesPermission extends AbstractPermission
{
    public ManageRelatedTablesPermission()
    {
        super("ManageRelatedTablesPermission", "This is the base permission required to perform CRUD operations on related tables");
    }
}
