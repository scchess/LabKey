/*
 * Copyright (c) 2015 LabKey Corporation
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
package org.labkey.mpower.query;

import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.module.Module;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.mpower.MPowerModule;
import org.labkey.mpower.MPowerSchema;

/**
 * Created by klum on 7/28/2015.
 */
public class MPowerQuerySchema extends SimpleUserSchema
{
    public static final String NAME = "mpower";
    public static final String DESCRIPTION = "Contains data for the MPower Prostate Survey";

    public static void register(final MPowerModule module)
    {
        DefaultSchema.registerProvider(NAME, new DefaultSchema.SchemaProvider(module)
        {
            @Override
            public QuerySchema createSchema(DefaultSchema schema, Module module)
            {
                return new MPowerQuerySchema(schema.getUser(), schema.getContainer());
            }
        });
    }

    public MPowerQuerySchema(User user, Container container)
    {
        super(NAME, DESCRIPTION, user, container, MPowerSchema.getInstance().getSchema());
    }

}
