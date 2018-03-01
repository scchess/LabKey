/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

package org.labkey.datstat;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.module.CodeOnlyModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.SystemMaintenance;
import org.labkey.api.view.WebPartFactory;

import java.util.Collection;
import java.util.Collections;

public class DatStatModule extends CodeOnlyModule
{
    public static final String NAME = "DatStat";

    @Override
    public String getName()
    {
        return NAME;
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
        addController(DatStatController.NAME, DatStatController.class);
    }

    @Override
    public void doStartup(ModuleContext moduleContext)
    {
        StudyService.get().registerStudyReloadSource(new DatStatReloadSource());

        //add the DATStat import task to the list of system maintenance tasks
        SystemMaintenance.addTask(new DatStatMaintenanceTask());
    }

    @Override
    @NotNull
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }
}