package org.labkey.tcrdb;

import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.laboratory.LaboratoryService;
import org.labkey.api.laboratory.NavItem;
import org.labkey.api.laboratory.QueryCountNavItem;
import org.labkey.api.laboratory.QueryImportNavItem;
import org.labkey.api.laboratory.QueryTabbedReportItem;
import org.labkey.api.laboratory.SimpleSettingsItem;
import org.labkey.api.laboratory.SummaryNavItem;
import org.labkey.api.laboratory.TabbedReportItem;
import org.labkey.api.ldk.table.QueryCache;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;
import org.labkey.api.sequenceanalysis.AbstractSequenceDataProvider;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/**
 * Created by bimber on 6/14/2016.
 */
public class TCRdbProvider extends AbstractSequenceDataProvider
{
    public static final String NAME = "TCRdb";
    private Module _module;

    public TCRdbProvider(Module module)
    {
        _module = module;
    }

    @Override
    public List<NavItem> getSequenceNavItems(Container c, User u, SequenceNavItemCategory category)
    {
        return Collections.emptyList();
    }

    @Override
    public List<NavItem> getMiscItems(Container c, User u)
    {
        return Collections.emptyList();
    }

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public ActionURL getInstructionsUrl(Container c, User u)
    {
        return null;
    }

    @Override
    public List<NavItem> getDataNavItems(Container c, User u)
    {
        List<NavItem> items = new ArrayList<>();
        QueryCache cache = new QueryCache();
        if (c.getActiveModules().contains(getOwningModule()))
        {
            TCRdbImportNavItem item = new TCRdbImportNavItem(this, "TCR Stims/Sorts", LaboratoryService.NavItemCategory.data, "TCRdb");
            item.setQueryCache(cache);
            items.add(item);
        }

        return Collections.unmodifiableList(items);
    }

    @Override
    public List<NavItem> getSampleNavItems(Container c, User u)
    {
        return Collections.emptyList();
    }

    @Override
    public List<NavItem> getSettingsItems(Container c, User u)
    {
        List<NavItem> items = new ArrayList<>();
        if (ContainerManager.getSharedContainer().equals(c))
        {
            items.add(new QueryImportNavItem(this, ContainerManager.getSharedContainer(), TCRdbSchema.NAME, TCRdbSchema.TABLE_LIBRARIES, LaboratoryService.NavItemCategory.settings, "MiXCR Libraries", NAME));
        }
        else
        {
            items.add(new SimpleSettingsItem(this, TCRdbSchema.NAME, "peptides", NAME, "Peptides/Stims"));
        }

        return items;
    }

    @Override
    public JSONObject getTemplateMetadata(ViewContext ctx)
    {
        return null;
    }

    @Override
    public Set<ClientDependency> getClientDependencies()
    {
        return null;
    }

    @Override
    public Module getOwningModule()
    {
        return _module;
    }

    @Override
    public List<SummaryNavItem> getSummary(Container c, User u)
    {
        List<SummaryNavItem> items = new ArrayList<>();

        items.add(new QueryCountNavItem(this, TCRdbSchema.NAME, "stims", LaboratoryService.NavItemCategory.data, LaboratoryService.NavItemCategory.data.name(),  "TCR Stims"));
        items.add(new QueryCountNavItem(this, TCRdbSchema.NAME, "sorts", LaboratoryService.NavItemCategory.data, LaboratoryService.NavItemCategory.data.name(), "TCR Sorts"));
        items.add(new QueryCountNavItem(this, TCRdbSchema.NAME, "cdnas", LaboratoryService.NavItemCategory.data, LaboratoryService.NavItemCategory.data.name(), "TCR cDNA Libraries"));

        return Collections.unmodifiableList(items);
    }

    @Override
    public List<NavItem> getSubjectIdSummary(Container c, User u, String subjectId)
    {
        return Collections.emptyList();
    }

    @Override
    public List<TabbedReportItem> getTabbedReportItems(Container c, User u)
    {
        if (!c.getActiveModules().contains(getOwningModule()))
        {
            return Collections.emptyList();
        }

        List<TabbedReportItem> items = new ArrayList<>();

        NavItem owner = getDataNavItems(c, u).get(0);
        String category = "TCRdb";
        QueryCache cache = new QueryCache();

        TabbedReportItem readsets = new QueryTabbedReportItem(cache, this, TCRdbSchema.NAME, TCRdbSchema.TABLE_STIMS, "TCR Stims/Blood Draws", category);
        readsets.setOwnerKey(owner.getPropertyManagerKey());
        items.add(readsets);

        TabbedReportItem analyses = new QueryTabbedReportItem(cache, this, TCRdbSchema.NAME, TCRdbSchema.TABLE_SORTS, "TCR Sorts", category);
        analyses.setSubjectIdFieldKey(FieldKey.fromString("stimId/animalId"));
        analyses.setSampleDateFieldKey(FieldKey.fromString("stimId/date"));
        analyses.setOwnerKey(owner.getPropertyManagerKey());
        items.add(analyses);

        TabbedReportItem outputs = new QueryTabbedReportItem(cache, this, TCRdbSchema.NAME, TCRdbSchema.TABLE_CDNAS, "TCR cDNA Libraries", category);
        outputs.setSubjectIdFieldKey(FieldKey.fromString("sortId/stimId/animalId"));
        outputs.setSampleDateFieldKey(FieldKey.fromString("sortId/stimId/date"));
        outputs.setOwnerKey(owner.getPropertyManagerKey());
        items.add(outputs);

        return items;
    }
}
