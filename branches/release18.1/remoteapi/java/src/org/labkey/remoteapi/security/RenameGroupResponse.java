/*
 * Copyright (c) 2009 LabKey Corporation
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
package org.labkey.remoteapi.security;

import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.Command;
import org.json.simple.JSONObject;

/*
* User: dave
* Date: Sep 28, 2009
* Time: 3:12:16 PM
*/
public class RenameGroupResponse extends CommandResponse
{
    public RenameGroupResponse(String text, int statusCode, String contentType, JSONObject json, Command sourceCommand)
    {
        super(text, statusCode, contentType, json, sourceCommand);
    }

    public String getOldName()
    {
        return getProperty("oldName");
    }

    public String getNewName()
    {
        return getProperty("newName");
    }
}
