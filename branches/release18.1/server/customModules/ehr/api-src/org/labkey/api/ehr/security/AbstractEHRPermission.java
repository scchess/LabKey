/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
package org.labkey.api.ehr.security;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Marker base class for permissions used by the EHR
 * User: bimber
 * Date: 8/6/13
 */
abstract public class AbstractEHRPermission extends AbstractPermission
{
    protected AbstractEHRPermission(@NotNull String name, @NotNull String description)
    {
        super(name, description);
    }
}
