/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
package org.labkey.api.data;

import org.jetbrains.annotations.Nullable;
import org.labkey.api.query.FieldKey;

import java.util.Map;

/**
 * User: matthewb
 * Date: 9/11/12
 * Time: 10:21 PM
 *
 * Should probably be included on DisplayColumnFactory.  However ther are a lot of implementations to update.
 * ColumnInfo calls checkLocked(), but be careful about modifying shared instances.
 */
public interface RemappingDisplayColumnFactory extends DisplayColumnFactory
{
    public void remapFieldKeys(@Nullable FieldKey parent, @Nullable Map<FieldKey, FieldKey> remap);
}
