/*
 * Copyright (c) 2010 LabKey Corporation
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

package gwt.client.org.labkey.plate.designer.client;

import gwt.client.org.labkey.plate.designer.client.model.GWTWellGroup;

/**
 * User: brittp
 * Date: Feb 9, 2007
 * Time: 12:28:27 PM
 */
public abstract class GroupChangeListenerAdapter implements GroupChangeListener
{
    public void activeGroupChanged(GWTWellGroup previouslyActive, GWTWellGroup currentlyActive)
    {
    }

    public void groupAdded(GWTWellGroup group)
    {
    }

    public void groupRemoved(GWTWellGroup group)
    {
    }

    public void activeGroupTypeChanged(String type)
    {
    }
}
