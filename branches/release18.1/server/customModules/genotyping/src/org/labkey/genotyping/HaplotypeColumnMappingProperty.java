/*
 * Copyright (c) 2012 LabKey Corporation
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
package org.labkey.genotyping;

/**
 * User: cnathe
 * Date: 10/29/12
 */
public class HaplotypeColumnMappingProperty
{
    String _name;
    String _label;
    boolean _required;

    public HaplotypeColumnMappingProperty(String name, String label, boolean required)
    {
        _name = name;
        _label = label;
        _required = required;
    }

    public String getName()
    {
        return _name;
    }

    public String getLabel()
    {
        return _label;
    }

    public boolean isRequired()
    {
        return _required;
    }
}
