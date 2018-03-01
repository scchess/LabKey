/*
 * Copyright (c) 2015-2017 LabKey Corporation
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

package org.labkey.mpower;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.view.WebPartFactory;
import org.labkey.mpower.query.MPowerQuerySchema;
import org.labkey.mpower.security.MPowerSecureSubmitterRole;

import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class MPowerModule extends DefaultModule
{
    public static final String NAME = "MPower";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public double getVersion()
    {
        return 18.10;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
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
        addController(MPowerController.NAME, MPowerController.class);
        addController(MPowerSecureController.NAME, MPowerSecureController.class);
    }

    @Override
    public void doStartup(ModuleContext moduleContext)
    {
        MPowerQuerySchema.register(this);

        // add a container listener so we'll know when our container is deleted:
        ContainerManager.addContainerListener(new MPowerContainerListener());

        // security roles
        RoleManager.registerRole(new MPowerSecureSubmitterRole());
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return Collections.singleton(MPowerSchema.NAME);
    }
}