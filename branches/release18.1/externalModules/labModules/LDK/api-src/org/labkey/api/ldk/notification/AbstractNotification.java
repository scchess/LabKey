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
package org.labkey.api.ldk.notification;

import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.module.Module;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.settings.AppProps;
import org.labkey.api.settings.LookAndFeelProperties;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

/**
 * User: bimber
 * Date: 1/7/14
 * Time: 5:30 PM
 */
abstract public class AbstractNotification implements Notification
{
    private Module _owner;

    protected final static Logger log = Logger.getLogger(AbstractNotification.class);
    protected final static SimpleDateFormat _timeFormat = new SimpleDateFormat("kk:mm");

    public AbstractNotification(Module owner)
    {
        _owner = owner;
    }

    public boolean isAvailable(Container c)
    {
        return c.getActiveModules().contains(_owner);
    }

    protected String getExecuteQueryUrl(Container c, String schemaName, String queryName, @Nullable String viewName)
    {
        return getExecuteQueryUrl(c, schemaName, queryName, viewName, null);
    }

    /**
     * This should really be using URLHelpers better, but there is a lot of legacy URL strings
     * migrated into java and its not worth changing all of it at this point
     */
    protected String getExecuteQueryUrl(Container c, String schemaName, String queryName, @Nullable String viewName, @Nullable SimpleFilter filter)
    {
        DetailsURL url = DetailsURL.fromString("/query/executeQuery.view", c);
        String ret = AppProps.getInstance().getBaseServerUrl() + url.getActionURL().toString();
        ret += "schemaName=" + schemaName + "&query.queryName=" + queryName;
        if (viewName != null)
            ret += "&query.viewName=" + viewName;

        if (filter != null)
            ret += "&" + filter.toQueryString("query");

        return ret;
    }

    public DateFormat getDateFormat(Container c)
    {
        return new SimpleDateFormat(LookAndFeelProperties.getInstance(c).getDefaultDateFormat());
    }

    public DateFormat getDateTimeFormat(Container c)
    {
        return new SimpleDateFormat(LookAndFeelProperties.getInstance(c).getDefaultDateTimeFormat());
    }
}
