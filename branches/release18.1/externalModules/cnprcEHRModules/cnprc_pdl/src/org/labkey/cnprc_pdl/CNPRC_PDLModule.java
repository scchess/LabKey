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

package org.labkey.cnprc_pdl;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.view.WebPartFactory;

import java.util.Collection;
import java.util.Collections;

public class CNPRC_PDLModule extends ExtendedSimpleModule
{
    public static final String NAME = "CNPRC_PDL";

    @Override
    public String getName()
    {
        return NAME;
    }

    @NotNull
    @Override
    public Collection<String> getSchemaNames()
    {
        return Collections.singleton(CNPRC_PDLSchema.SCHEMA_NAME);
    }

    @Override
    public double getVersion()
    {
        return 16.24;
    }

    @Override
    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return Collections.emptyList();
    }

    @Override
    protected void init()
    {
        addController(CNPRC_PDLController.NAME, CNPRC_PDLController.class);
    }

    @Override
    @NotNull
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }

}