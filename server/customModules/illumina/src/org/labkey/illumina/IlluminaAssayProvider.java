/*
 * Copyright (c) 2010-2014 LabKey Corporation
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
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.exp.Lsid;
import org.labkey.api.exp.api.ExpData;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.exp.property.PropertyService;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.pipeline.PipelineProvider;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;
import org.labkey.api.study.actions.AssayRunUploadForm;
import org.labkey.api.study.assay.AbstractAssayProvider;
import org.labkey.api.study.assay.AssayDataCollector;
import org.labkey.api.study.assay.AssayDataType;
import org.labkey.api.study.assay.AssayProtocolSchema;
import org.labkey.api.study.assay.AssayRunCreator;
import org.labkey.api.study.assay.AssayTableMetadata;
import org.labkey.api.study.assay.AssayUrls;
import org.labkey.api.study.assay.ParticipantVisitResolverType;
import org.labkey.api.util.FileType;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.ViewContext;

import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * User: jeckels
 * Date: Sep 7, 2010
 */
public class IlluminaAssayProvider extends AbstractAssayProvider
{
    public static final String PROTOCOL_PREFIX = "IlluminaAssayProtocol";
    public static final String RUN_PREFIX = "IlluminaAssayRun";
    public static final String NAME = "Illumina";

    public static final AssayDataType INPUT_TYPE =
            new AssayDataType("IlluminaAssayData", new FileType("BogusExtension"));

    public IlluminaAssayProvider()
    {
        super(PROTOCOL_PREFIX, RUN_PREFIX, INPUT_TYPE, ModuleLoader.getInstance().getModule(IlluminaModule.class));
    }

    @Override
    public ExpData getDataForDataRow(Object dataRowId, ExpProtocol protocol)
    {
        return null;
    }

    @Override
    public String getName()
    {
        return NAME;
    }

    @NotNull
    @Override
    public AssayTableMetadata getTableMetadata(@NotNull ExpProtocol protocol)
    {
        return new AssayTableMetadata(
                this,
                protocol,
                null,
                FieldKey.fromParts("Run"),
                FieldKey.fromParts("ObjectId")
        );
    }

    @Override
    public Domain getResultsDomain(ExpProtocol protocol)
    {
        try
        {
            return super.getResultsDomain(protocol);
        }
        catch (IllegalArgumentException e)
        {
            // Illumina don't yet implement any results import yet, but this prevents us from dying trying to
            // figure out if we should render a copy to study button on the toolbar
            return PropertyService.get().createDomain(protocol.getContainer(), new Lsid(ExpProtocol.ASSAY_DOMAIN_DATA, "Folder-" + protocol.getContainer().getRowId(), protocol.getName()).toString(), "Results");
        }
    }

    @Override
    public HttpView getDataDescriptionView(AssayRunUploadForm form)
    {
        return new HtmlView("Illumina assays are not yet associated with result data");
    }

    @Override
    public List<ParticipantVisitResolverType> getParticipantVisitResolverTypes()
    {
        return Collections.emptyList();
    }

    @Override
    public PipelineProvider getPipelineProvider()
    {
        // Not yet hooked up when browsing files
        return null;
    }

    @Override
    public String getDescription()
    {
        return "Tracks basic run level metadata for Illumina assay runs";
    }

    @Override
    public AssayRunCreator getRunCreator()
    {
        return new IlluminaRunCreator(this);
    }

    @Override
    public ActionURL getImportURL(Container container, ExpProtocol protocol)
    {
        return PageFlowUtil.urlProvider(AssayUrls.class).getProtocolURL(container, protocol, IlluminaUploadWizardAction.class);
    }

    @Override
    public List<AssayDataCollector> getDataCollectors(Map<String, File> uploadedFiles, AssayRunUploadForm context)
    {
        return Collections.emptyList();
    }

    @Override
    public AssayProtocolSchema createProtocolSchema(User user, Container container, @NotNull ExpProtocol protocol, @Nullable Container targetStudy)
    {
        return new IlluminaProtocolSchema(user, container, this, protocol, targetStudy);
    }

    @Override
    public List<NavTree> getHeaderLinks(ViewContext viewContext, ExpProtocol protocol, ContainerFilter containerFilter)
    {
        return Collections.emptyList();
    }

    @Override
    public boolean isEditableRuns(ExpProtocol protocol)
    {
        // Override to make default value true
        Boolean b = getBooleanProperty(protocol, EDITABLE_RUNS_PROPERTY_SUFFIX);
        return b == null || b.booleanValue();
    }
}
