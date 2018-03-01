package org.scharp.atlas.specimentracking;

import org.apache.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.BaseWebPartFactory;
import org.labkey.api.view.Portal;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.WebPartView;
import org.scharp.atlas.specimentracking.view.SpecimentrackingWebPart;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class SpecimentrackingModule extends DefaultModule
{
    private static final Logger _log = Logger.getLogger(DefaultModule.class);
    //public static final String NAME = "Specimentracking";
    public static final String NAME = "Specimen_tracking";

    public String getName()
    {
        return NAME;
    }

    public double getVersion()
    {
        return 1.04;
    }

    protected void init()
    {
        addController("specimen_tracking", SpecimentrackingController.class);
    }

    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return new ArrayList<WebPartFactory>(Arrays.asList(new BaseWebPartFactory("Specimentracking Summary", WebPartFactory.LOCATION_BODY, WebPartFactory.LOCATION_RIGHT) {
                {
                    addLegacyNames("Narrow Specimentracking Summary");
                }

                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    return new SpecimentrackingWebPart();
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
        ContainerManager.addContainerListener(new SpecimentrackingContainerListener());
    }

    @NotNull
    public Set<String> getSchemaNames()
    {
        return PageFlowUtil.set(SpecimentrackingSchema.getInstance().getSchemaName());
    }

    @NotNull
    public Set<DbSchema> getSchemasToTest()
    {
        return PageFlowUtil.set(SpecimentrackingSchema.getInstance().getSchema());
    }
}
