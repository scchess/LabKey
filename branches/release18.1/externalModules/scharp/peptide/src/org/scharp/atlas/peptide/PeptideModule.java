package org.scharp.atlas.peptide;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.view.*;
import org.labkey.api.util.PageFlowUtil;
import org.scharp.atlas.peptide.view.PeptideWebPart;
import org.apache.log4j.Logger;

import java.util.*;
import java.lang.reflect.InvocationTargetException;

public class PeptideModule extends DefaultModule
{
    private static final Logger _log = Logger.getLogger(DefaultModule.class);
    public static final String NAME = "Peptide";

    public String getName()
    {
        return NAME;
    }

    public double getVersion()
    {
        return 0.09;
    }

    protected void init()
    {
       addController("peptide", PeptideController.class);
    }

    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return new ArrayList<WebPartFactory>(Arrays.asList(new BaseWebPartFactory("Peptide Summary", WebPartFactory.LOCATION_BODY, WebPartFactory.LOCATION_RIGHT) {
                {
                    addLegacyNames("Narrow Peptide Summary");
                }

                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    return new PeptideWebPart();
                }
            }));
    }
    
    public boolean hasScripts()
    {
        return true;
    }

    @NotNull
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }

    public void doStartup(ModuleContext moduleContext)
    {
        // add a container listener so we'll know when our container is deleted:
        ContainerManager.addContainerListener(new PeptideContainerListener());
    }
    @NotNull
    public Set<String> getSchemaNames()
    {
        return PageFlowUtil.set(PeptideSchema.getInstance().getSchemaName());
    }

    @NotNull
    public Set<DbSchema> getSchemasToTest()
    {
        return PageFlowUtil.set(PeptideSchema.getInstance().getSchema());
    }
}
