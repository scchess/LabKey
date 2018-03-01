/*
 * Copyright (c) 2013 LabKey Corporation
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

package org.labkey.skylinetoolsstore;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.dialect.SqlDialect;
import org.labkey.api.data.TableInfo;

import java.lang.String;

public class SkylineToolsStoreSchema
{
    private static final SkylineToolsStoreSchema _instance = new SkylineToolsStoreSchema();
    private static final String SCHEMA_NAME = "skylinetoolsstore";

    public static SkylineToolsStoreSchema getInstance()
    {
        return _instance;
    }

    private SkylineToolsStoreSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.skylinetoolsstore.SkylineToolsStoreSchema.getInstance()
    }

    public String getSchemaName()
    {
        return SCHEMA_NAME;
    }

    public DbSchema getSchema()
    {
        return DbSchema.get(SCHEMA_NAME);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }

    public TableInfo getTableInfoSkylineTool()
    {
        return getSchema().getTable("SkylineTool");
    }

    public TableInfo getTableInfoRating()
    {
        return getSchema().getTable("Rating");
    }
}
