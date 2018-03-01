/*
 * Copyright (c) 2007-2013 LabKey Corporation
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

package org.labkey.api.gwt.client.util;

import com.google.gwt.user.client.rpc.IsSerializable;

/**
 * User: Matthew
 * Date: Apr 25, 2007
 * Time: 4:43:06 PM
 */
public class BooleanProperty implements IPropertyWrapper, IsSerializable
{
    Boolean b;

    public BooleanProperty()
    {
        b = null;
    }

    public BooleanProperty(boolean b)
    {
        setBool(b);
    }

    public BooleanProperty(Boolean b)
    {
        set(b);
    }

    public Object get()
    {
        return b;
    }

    public void set(Object o)
    {
        if (o instanceof String)
            b = Boolean.valueOf((String)o);
        else if (o instanceof Boolean)
            b = (Boolean)o;
        else
            throw new IllegalArgumentException(String.valueOf(o));
    }

    public Boolean getBoolean()
    {
        return b;
    }

    public void setBool(boolean b)
    {
        this.b = Boolean.valueOf(b);
    }

    public boolean booleanValue()
    {
        return b != null && b.booleanValue();
    }

    @Deprecated
    public boolean getBool()
    {
        return b != null && b.booleanValue();
    }

    public String toString()
    {
        return String.valueOf(b);
    }
}
