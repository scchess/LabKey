/*
 * Copyright (c) 2008-2016 LabKey Corporation
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
package org.labkey.api.pipeline;

import org.jetbrains.annotations.Nullable;

/**
 * Extra interface methods for {@link TaskFactory}s that need to work with temporary files.
 * User: jeckels
 * Date: Sep 11, 2008
 */
public abstract class WorkDirectoryTask<FactoryType extends TaskFactory> extends PipelineJob.Task<FactoryType>
{
    protected WorkDirectory _wd;

    public WorkDirectoryTask(FactoryType factory, PipelineJob job)
    {
        super(factory, job);
    }

    public void setWorkDirectory(@Nullable WorkDirectory wd)
    {
        _wd = wd;
    }
}