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
package org.labkey.api.ehr.history;

import org.labkey.api.ehr.history.SortingLabworkType;
import org.labkey.api.module.Module;

/**
 * User: bimber
 * Date: 3/6/13
 * Time: 11:38 AM
 */
public class ChemistryLabworkType extends SortingLabworkType
{
    public ChemistryLabworkType(Module module)
    {
        super("Biochemistry", "study", "chemistryRefRange", "Biochemistry", module);
        _normalRangeField = "range";
        _normalRangeStatusField = "status";
    }
}