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

package org.labkey.flowassays;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.dialect.SqlDialect;

public class FlowAssaysSchema
{
    private static final FlowAssaysSchema _instance = new FlowAssaysSchema();
    public static final String NAME = "flowassays";
    public static final String TABLE_POPULATIONS = "populations";

    public static FlowAssaysSchema getInstance()
    {
        return _instance;
    }

    private FlowAssaysSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.flowassays.FlowAssaysSchema.getInstance()
    }

    public DbSchema getSchema()
    {
        return DbSchema.get(NAME);
    }

    public TableInfo getTable(String name)
    {
        return _instance.getSchema().getTable(name);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }
}
