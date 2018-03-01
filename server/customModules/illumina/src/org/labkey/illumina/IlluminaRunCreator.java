/*
 * Copyright (c) 2011-2014 LabKey Corporation
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

import org.labkey.api.exp.ExperimentException;
import org.labkey.api.exp.api.ExpData;
import org.labkey.api.exp.api.ExpDataRunInput;
import org.labkey.api.exp.api.ExpMaterial;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.study.assay.AssayRunUploadContext;
import org.labkey.api.study.assay.DefaultAssayRunCreator;
import org.labkey.api.study.assay.ParticipantVisitResolverType;
import org.labkey.api.study.assay.SampleChooserDisplayColumn;

import java.util.Map;

/**
 * User: jeckels
 * Date: Oct 12, 2011
 */
public class IlluminaRunCreator extends DefaultAssayRunCreator<IlluminaAssayProvider>
{
    public IlluminaRunCreator(IlluminaAssayProvider provider)
    {
        super(provider);
    }

    @Override
    protected void addInputMaterials(AssayRunUploadContext<IlluminaAssayProvider> context, Map<ExpMaterial, String> inputMaterials, ParticipantVisitResolverType resolverType) throws ExperimentException
    {
        super.addInputMaterials(context, inputMaterials, resolverType);

        int sampleCount = SampleChooserDisplayColumn.getSampleCount(context.getRequest(), IlluminaUploadWizardAction.MAX_SAMPLES);
        for (int i = 0; i < sampleCount; i++)
        {
            ExpMaterial material = SampleChooserDisplayColumn.getMaterial(i, context.getContainer(), context.getRequest());

            if (!material.getContainer().hasPermission(context.getUser(), ReadPermission.class))
            {
                throw new ExperimentException("You do not have permission to reference the sample '" + material.getName() + ".");
            }
            if (inputMaterials.containsKey(material))
            {
                throw new ExperimentException("The same material, '" + material.getName() + "', cannot be used multiple times for a single run");
            }
            inputMaterials.put(material, "Sample " + (i + 1));
        }
    }

    @Override
    protected void addOutputDatas(AssayRunUploadContext<IlluminaAssayProvider> context, Map<ExpData, String> inputDatas, Map<ExpData, String> outputDatas, ParticipantVisitResolverType resolverType) throws ExperimentException
    {
        ExpData data = ExperimentService.get().createData(context.getContainer(), getProvider().getDataType(), "Illumina output placeholder");
        data.setLSID(ExperimentService.get().generateGuidLSID(context.getContainer(), getProvider().getDataType()));
        outputDatas.put(data, ExpDataRunInput.DEFAULT_ROLE);
    }

}
