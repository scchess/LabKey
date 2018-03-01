/*
 * Copyright (c) 2009-2010 LabKey Corporation
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

package org.labkey.study.pipeline;

import org.labkey.api.pipeline.AbstractTaskFactorySettings;
import org.labkey.api.pipeline.AbstractTaskFactory;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.util.FileType;

import java.util.List;
import java.util.Collections;

public abstract class AbstractSpecimenTaskFactory<FactoryType extends AbstractSpecimenTaskFactory<FactoryType>> extends AbstractTaskFactory<AbstractTaskFactorySettings, FactoryType>
{
    AbstractSpecimenTaskFactory(Class namespaceClass)
    {
        super(namespaceClass);
    }

    public List<FileType> getInputTypes()
    {
        return Collections.emptyList();
    }

    public List<String> getProtocolActionNames()
    {
        return Collections.emptyList();
    }

    public String getStatusName()
    {
        return "LOAD SPECIMENS";
    }

    public boolean isJobComplete(PipelineJob job)
    {
        return false;
    }
}
