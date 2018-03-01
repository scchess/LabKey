/*
 * Copyright (c) 2009-2012 LabKey Corporation
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
package org.labkey.study.security.permissions;

import org.labkey.api.security.permissions.AbstractPermission;
import org.labkey.study.StudyModule;

/*
* User: Dave
* Date: May 18, 2009
* Time: 11:30:46 AM
*/
public class ManageDisplaySettingsPermission extends AbstractPermission
{
    public ManageDisplaySettingsPermission()
    {
        super("Manage Specimen Display Settings",
                "Allows management of display settings on the specimen request form",
                StudyModule.class);
    }
}