/*
 * Copyright (c) 2006-2008 LabKey Corporation
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

package org.labkey.api.study;

import org.labkey.api.data.Container;

import java.util.List;
import java.util.Set;

/**
 * User: brittp
 * Date: Oct 20, 2006
 * Time: 5:12:37 PM
 */
public interface PropertySet
{
    Set<String> getPropertyNames();

    void setProperty(String name, Object value);

    Object getProperty(String name);

    Container getContainer();
    
    String getLSID();
}
