/*
 * Copyright (c) 2014 LabKey Corporation
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

package org.labkey.galaxyintegration;

import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.Nullable;
import org.json.JSONException;
import org.json.JSONObject;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.security.User;

import java.util.Map;

public class GalaxyIntegrationManager
{
    private static final GalaxyIntegrationManager _instance = new GalaxyIntegrationManager();

    private GalaxyIntegrationManager()
    {
        // prevent external construction with a private default constructor
    }

    public static GalaxyIntegrationManager get()
    {
        return _instance;
    }

    public static final String GALAXY_KEY = "GalaxyIntegrationApiKey";

    /**
     *
     * @param user
     * @param hostName
     * @param apiKey Use NULL to clear this hostName
     */
    public void saveApiKey(User user, String hostName, @Nullable String url, @Nullable String apiKey)
    {
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(user, ContainerManager.getRoot(), GALAXY_KEY, true);
        if (StringUtils.trimToNull(url) != null)
        {
            JSONObject props = new JSONObject();
            props.put("url", url);
            props.put("apiKey", apiKey);

            map.put(hostName, props.toString());
        }
        else
        {
            map.remove(hostName);
        }

        map.save();
    }

    @Nullable
    public JSONObject getServerSettings(User user, String hostName)
    {
        Map<String, String> map = PropertyManager.getProperties(user, ContainerManager.getRoot(), GALAXY_KEY);
        if (map == null || map.get(hostName) == null)
        {
            return null;
        }

        try
        {
            return new JSONObject(map.get(hostName));
        }
        catch (JSONException e)
        {
            //ignore
        }

        return null;
    }
}