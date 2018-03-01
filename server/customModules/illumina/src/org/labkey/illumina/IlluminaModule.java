/*
 * Copyright (c) 2010-2016 LabKey Corporation
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

package org.labkey.illumina;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.exp.Identifiable;
import org.labkey.api.exp.Lsid;
import org.labkey.api.exp.LsidManager;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.exp.api.ExperimentUrls;
import org.labkey.api.module.CodeOnlyModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.study.assay.AssayService;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.WebPartFactory;

import java.util.Collection;
import java.util.Collections;

public class IlluminaModule extends CodeOnlyModule
{
    public String getName()
    {
        return "Illumina";
    }

    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return Collections.emptyList();
    }

    protected void init()
    {
        addController("illumina", IlluminaController.class);
    }

    public void doStartup(ModuleContext moduleContext)
    {
        AssayService.get().registerAssayProvider(new IlluminaAssayProvider());
        LsidManager.get().registerHandler(IlluminaAssayProvider.RUN_PREFIX, new LsidManager.LsidHandler()
        {
            @Override
            public Identifiable getObject(Lsid lsid)
            {
                return ExperimentService.get().getExpRun(lsid.toString());
            }

            @Nullable
            @Override
            public ActionURL getDisplayURL(Lsid lsid)
            {
                ExpRun run = ExperimentService.get().getExpRun(lsid.toString());
                if (run != null)
                {
                    return PageFlowUtil.urlProvider(ExperimentUrls.class).getRunTextURL(run);
                }
                return null;
            }

            @Override
            public Container getContainer(Lsid lsid)
            {
                ExpRun run = ExperimentService.get().getExpRun(lsid.toString());
                if (run != null)
                {
                    return run.getContainer();
                }
                return null;
            }

            @Override
            public boolean hasPermission(Lsid lsid, @NotNull User user, @NotNull Class<? extends Permission> perm)
            {
                ExpRun run = ExperimentService.get().getExpRun(lsid.toString());
                return run != null && run.getContainer().hasPermission(user, perm);
            }
        });
    }

    @NotNull
    @Override
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }
}