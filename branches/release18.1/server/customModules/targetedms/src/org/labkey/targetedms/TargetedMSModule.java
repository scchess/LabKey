/*
 * Copyright (c) 2012-2017 LabKey Corporation
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

package org.labkey.targetedms;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.audit.AuditLogService;
import org.labkey.api.cloud.CloudStoreService;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.UpgradeCode;
import org.labkey.api.exp.ExperimentRunType;
import org.labkey.api.exp.ExperimentRunTypeSource;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.module.FolderTypeManager;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.module.ModuleProperty;
import org.labkey.api.module.SpringModule;
import org.labkey.api.pipeline.PipelineService;
import org.labkey.api.protein.ProteinService;
import org.labkey.api.protein.ProteomicsModule;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.services.ServiceRegistry;
import org.labkey.api.settings.AdminConsole;
import org.labkey.api.targetedms.TargetedMSService;
import org.labkey.api.usageMetrics.UsageMetricsService;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.BaseWebPartFactory;
import org.labkey.api.view.JspView;
import org.labkey.api.view.Portal;
import org.labkey.api.view.ShortURLService;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.WebPartView;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.webdav.WebdavService;
import org.labkey.targetedms.chart.ComparisonCategory;
import org.labkey.targetedms.chart.ReplicateLabelMinimizer;
import org.labkey.targetedms.pipeline.CopyExperimentPipelineProvider;
import org.labkey.targetedms.pipeline.TargetedMSPipelineProvider;
import org.labkey.targetedms.search.ModificationSearchWebPart;
import org.labkey.targetedms.security.CopyTargetedMSExperimentRole;
import org.labkey.targetedms.view.LibraryPrecursorViewWebPart;
import org.labkey.targetedms.view.PeptideGroupViewWebPart;
import org.labkey.targetedms.view.PeptideViewWebPart;
import org.labkey.targetedms.view.TargetedMSRunsWebPartView;
import org.labkey.targetedms.view.TransitionPeptideSearchViewProvider;
import org.labkey.targetedms.view.TransitionProteinSearchViewProvider;
import org.labkey.targetedms.view.expannotations.TargetedMSExperimentWebPart;
import org.labkey.targetedms.view.expannotations.TargetedMSExperimentsWebPart;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class TargetedMSModule extends SpringModule implements ProteomicsModule
{
    public static final String NAME = "TargetedMS";

    // Protocol prefix for importing .sky documents from Skyline
    public static final String IMPORT_SKYDOC_PROTOCOL_OBJECT_PREFIX = "TargetedMS.ImportSky";
    // Protocol prefix for importing .zip archives from Skyline
    public static final String IMPORT_SKYZIP_PROTOCOL_OBJECT_PREFIX = "TargetedMS.ImportSkyZip";

    public static final ExperimentRunType EXP_RUN_TYPE = new TargetedMSExperimentRunType();
    public static final String TARGETED_MS_SETUP = "Targeted MS Setup";
    public static final String TARGETED_MS_CHROMATOGRAM_LIBRARY_DOWNLOAD = "Chromatogram Library Download";
    public static final String TARGETED_MS_PRECURSOR_VIEW = "Targeted MS Precursor View";
    public static final String TARGETED_MS_PEPTIDE_VIEW = "Targeted MS Peptide View";
    public static final String TARGETED_MS_PEPTIDE_GROUP_VIEW = "Targeted MS Protein View";
    public static final String TARGETED_MS_RUNS_WEBPART_NAME = "Targeted MS Runs";
    public static final String TARGETED_MS_PROTEIN_SEARCH = "Targeted MS Protein Search";
    public static final String TARGETED_MS_QC_SUMMARY = "Targeted MS QC Summary";
    public static final String TARGETED_MS_QC_PLOTS = "Targeted MS QC Plots";
    public static final String MASS_SPEC_SEARCH_WEBPART = "Mass Spec Search (Tabbed)";
    public static final String TARGETED_MS_PARETO_PLOT = "Targeted MS Pareto Plot";

    public static final String[] EXPERIMENT_FOLDER_WEB_PARTS = new String[] {MASS_SPEC_SEARCH_WEBPART,
                                                                           TARGETED_MS_RUNS_WEBPART_NAME};

    public static final String[] LIBRARY_FOLDER_WEB_PARTS = new String[] {TARGETED_MS_CHROMATOGRAM_LIBRARY_DOWNLOAD,
                                                                          MASS_SPEC_SEARCH_WEBPART,
                                                                          TARGETED_MS_PEPTIDE_VIEW,
                                                                          TARGETED_MS_PRECURSOR_VIEW,
                                                                          TARGETED_MS_RUNS_WEBPART_NAME};

    public static final String[] PROTEIN_LIBRARY_FOLDER_WEB_PARTS = new String[] {TARGETED_MS_CHROMATOGRAM_LIBRARY_DOWNLOAD,
                                                                          MASS_SPEC_SEARCH_WEBPART,
                                                                          TARGETED_MS_PEPTIDE_GROUP_VIEW,
                                                                          TARGETED_MS_PEPTIDE_VIEW,
                                                                          TARGETED_MS_PRECURSOR_VIEW,
                                                                          TARGETED_MS_RUNS_WEBPART_NAME};

    public static final String[] QC_FOLDER_WEB_PARTS = new String[] {TARGETED_MS_QC_SUMMARY, TARGETED_MS_QC_PLOTS};

    public static final String TARGETED_MS_FOLDER_TYPE = "TargetedMS Folder Type";
    public static ModuleProperty FOLDER_TYPE_PROPERTY;
    public static final String AUTO_QC_PING_TIMEOUT = "TargetedMS AutoQCPing Timeout";

    public enum FolderType
    {
        Experiment, Library, LibraryProtein, QC, Undefined
    }

    public TargetedMSModule()
    {
        FOLDER_TYPE_PROPERTY = new ModuleProperty(this, TARGETED_MS_FOLDER_TYPE);
        // Set up the TargetedMS Folder Type property
        FOLDER_TYPE_PROPERTY.setDefaultValue(FolderType.Undefined.toString());
        FOLDER_TYPE_PROPERTY.setCanSetPerContainer(true);
        FOLDER_TYPE_PROPERTY.setShowDescriptionInline(true);
        addModuleProperty(FOLDER_TYPE_PROPERTY);

        // setup the QC Summary webpart AutoQCPing timeout
        ModuleProperty autoQCPingProp = new ModuleProperty(this, AUTO_QC_PING_TIMEOUT);
        autoQCPingProp.setDescription("The number of minutes before the most recent AutoQCPing indicator is considered stale.");
        autoQCPingProp.setDefaultValue("15");
        autoQCPingProp.setShowDescriptionInline(true);
        autoQCPingProp.setCanSetPerContainer(true);
        addModuleProperty(autoQCPingProp);
    }

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

    @NotNull
    @Override
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        BaseWebPartFactory setupFactory = new BaseWebPartFactory(TARGETED_MS_SETUP)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                JspView view = new JspView("/org/labkey/targetedms/view/folderSetup.jsp");
                view.setTitle(TargetedMSController.CONFIGURE_TARGETED_MS_FOLDER);
                return view;
            }

            @Override
            public String getDisplayName(Container container, String location)
            {
                return "Panorama Setup";
            }
        };

        BaseWebPartFactory chromatogramLibraryDownload = new BaseWebPartFactory(TARGETED_MS_CHROMATOGRAM_LIBRARY_DOWNLOAD)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                JspView view = new JspView("/org/labkey/targetedms/view/chromatogramLibraryDownload.jsp");
                view.setTitle(TARGETED_MS_CHROMATOGRAM_LIBRARY_DOWNLOAD);
                return view;
            }
        };
        BaseWebPartFactory precursorView = new BaseWebPartFactory(TARGETED_MS_PRECURSOR_VIEW)
        {
            @Override
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
               return new LibraryPrecursorViewWebPart(portalCtx);
            }
        };

        BaseWebPartFactory peptideView  = new BaseWebPartFactory(TARGETED_MS_PEPTIDE_VIEW)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new PeptideViewWebPart(portalCtx);
            }
        };

        BaseWebPartFactory peptideGroupView  = new BaseWebPartFactory(TARGETED_MS_PEPTIDE_GROUP_VIEW)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new PeptideGroupViewWebPart(portalCtx);
            }
        };

        BaseWebPartFactory runsFactory = new BaseWebPartFactory(TARGETED_MS_RUNS_WEBPART_NAME)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new TargetedMSRunsWebPartView(portalCtx);
            }
        };

        BaseWebPartFactory proteinSearchFactory = new BaseWebPartFactory(TARGETED_MS_PROTEIN_SEARCH)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                JspView view = new JspView("/org/labkey/targetedms/view/proteinSearch.jsp");
                view.setTitle("Protein Search");
                return view;
            }
        };

        BaseWebPartFactory modificationSearchFactory = new BaseWebPartFactory(ModificationSearchWebPart.NAME)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new ModificationSearchWebPart(TargetedMSController.ModificationSearchForm.createDefault());
            }
        };

        BaseWebPartFactory experimentAnnotationsListFactory = new BaseWebPartFactory(TargetedMSExperimentsWebPart.WEB_PART_NAME)
        {
            @Override
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new TargetedMSExperimentsWebPart(portalCtx);
            }
        };

        BaseWebPartFactory containerExperimentFactory = new BaseWebPartFactory(TargetedMSExperimentWebPart.WEB_PART_NAME)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new TargetedMSExperimentWebPart(portalCtx);
            }
        };

        BaseWebPartFactory qcPlotsFactory = new BaseWebPartFactory(TARGETED_MS_QC_PLOTS)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                JspView result = new JspView("/org/labkey/targetedms/view/qcTrendPlotReport.jsp");
                result.addClientDependency(ClientDependency.fromPath("Ext4"));
                result.setTitle("QC Plots");
                result.setFrame(WebPartView.FrameType.PORTAL);
                return result;
            }
        };

        BaseWebPartFactory qcSummaryFactory = new BaseWebPartFactory(TARGETED_MS_QC_SUMMARY)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                JspView result = new JspView("/org/labkey/targetedms/view/qcSummary.jsp");
                result.addClientDependency(ClientDependency.fromPath("Ext4"));
                result.setTitle("QC Summary");
                result.setFrame(WebPartView.FrameType.PORTAL);
                return result;
            }
        };

        BaseWebPartFactory paretoPlotFactory = new BaseWebPartFactory(TARGETED_MS_PARETO_PLOT)
        {
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                JspView result = new JspView("/org/labkey/targetedms/view/paretoPlot.jsp");
                result.addClientDependency(ClientDependency.fromPath("Ext4"));
                result.setTitle("Pareto Plots");
                result.setFrame(WebPartView.FrameType.PORTAL);
                return result;
            }
        };

        List<WebPartFactory> webpartFactoryList = new ArrayList<>();
        webpartFactoryList.add(setupFactory);
        webpartFactoryList.add(chromatogramLibraryDownload);
        webpartFactoryList.add(precursorView);
        webpartFactoryList.add(peptideView);
        webpartFactoryList.add(peptideGroupView);
        webpartFactoryList.add(runsFactory);
        webpartFactoryList.add(proteinSearchFactory);
        webpartFactoryList.add(modificationSearchFactory);
        webpartFactoryList.add(experimentAnnotationsListFactory);
        webpartFactoryList.add(containerExperimentFactory);
        webpartFactoryList.add(qcPlotsFactory);
        webpartFactoryList.add(qcSummaryFactory);
        webpartFactoryList.add(paretoPlotFactory);
        return webpartFactoryList;
    }

    @NotNull
    @Override
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return PageFlowUtil.set(TargetedMSManager.get().getSchemaName());
    }

    @Override
    protected void init()
    {
        addController("targetedms", TargetedMSController.class);
        TargetedMSSchema.register(this);

        UsageMetricsService svc = ServiceRegistry.get().getService(UsageMetricsService.class);
        if (null != svc)
        {
            svc.registerUsageMetrics(NAME, () ->
            {
                Map<String, Object> metric = new HashMap<>();
                metric.put("runCount", new SqlSelector(DbSchema.get("TargetedMS", DbSchemaType.Module), "SELECT COUNT(*) FROM TargetedMS.Runs WHERE Deleted = ?", Boolean.FALSE).getObject(Long.class));
                return metric;
            });
        }
    }

    @Override
    protected void startupAfterSpringConfig(ModuleContext moduleContext)
    {
        PipelineService service = PipelineService.get();
        service.registerPipelineProvider(new TargetedMSPipelineProvider(this));
        service.registerPipelineProvider(new CopyExperimentPipelineProvider(this));

        ExperimentService.get().registerExperimentDataHandler(new TargetedMSDataHandler());
        ExperimentService.get().registerExperimentDataHandler(new SkylineBinaryDataHandler());

        ExperimentService.get().registerExperimentRunTypeSource(new ExperimentRunTypeSource()
        {
            @NotNull
            public Set<ExperimentRunType> getExperimentRunTypes(@Nullable Container container)
            {
                if (container == null || container.getActiveModules().contains(TargetedMSModule.this))
                {
                    return Collections.singleton(EXP_RUN_TYPE);
                }
                return Collections.emptySet();
            }
        });

        //register the Targeted MS folder type
        FolderTypeManager.get().registerFolderType(this, new TargetedMSFolderType(this));

        ProteinService proteinService = ServiceRegistry.get().getService(ProteinService.class);
        proteinService.registerProteinSearchView(new TransitionProteinSearchViewProvider());
        proteinService.registerPeptideSearchView(new TransitionPeptideSearchViewProvider());

        ServiceRegistry svcReg = ServiceRegistry.get();
        svcReg.registerService(TargetedMSService.class, new TargetedMSServiceImpl());

        AuditLogService.get().registerAuditType(new TargetedMsRepresentativeStateAuditProvider());

        TargetedMSListener listener = new TargetedMSListener();
        ExperimentService.get().addExperimentListener(listener);
        ContainerManager.addContainerListener(listener);

        ShortURLService shortUrlService = ServiceRegistry.get().getService(ShortURLService.class);
        shortUrlService.addListener(listener);

        // Register the CopyExperimentRole
        RoleManager.registerRole(new CopyTargetedMSExperimentRole());

		// Add a link in the admin console to manage journals.
		ActionURL url =  new ActionURL(PublishTargetedMSExperimentsController.JournalGroupsAdminViewAction.class, ContainerManager.getRoot());
        AdminConsole.addLink(AdminConsole.SettingsLinkType.Configuration, "targeted ms", url, AdminPermission.class);
    }

    @NotNull
    @Override
    public Set<Class> getIntegrationTests()
    {
        return Collections.singleton(PublishTargetedMSExperimentsController.TestCase.class);
    }

    @NotNull
    @Override
    public Set<Class> getUnitTests()
    {
        Set<Class> set = new HashSet<>();
        set.add(TargetedMSController.TestCase.class);
        set.add(ComparisonCategory.TestCase.class);
        set.add(ReplicateLabelMinimizer.TestCase.class);
        return set;

    }

    @Override
    public UpgradeCode getUpgradeCode()
    {
        return new TargetedMSUpgradeCode();
    }

    public static FolderType getFolderType(@NotNull Container container)
    {
        TargetedMSModule targetedMSModule = null;
        for (Module m : container.getActiveModules())
        {
            if (m instanceof TargetedMSModule)
            {
                targetedMSModule = (TargetedMSModule) m;
                break;
            }
        }
        if (targetedMSModule != null)
        {
            ModuleProperty moduleProperty = targetedMSModule.getModuleProperties().get(TARGETED_MS_FOLDER_TYPE);
            return FolderType.valueOf(moduleProperty.getValueContainerSpecific(container));
        }

        return null;
    }
}
