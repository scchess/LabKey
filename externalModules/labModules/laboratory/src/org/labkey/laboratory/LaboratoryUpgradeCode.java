package org.labkey.laboratory;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSequenceManager;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.data.UpgradeCode;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * User: bimber
 * Date: 1/31/13
 * Time: 8:29 PM
 */
public class LaboratoryUpgradeCode implements UpgradeCode
{
    private static final Logger _log = Logger.getLogger(LaboratoryUpgradeCode.class);

    /** called at 12.277-12.278 */
    @SuppressWarnings({"UnusedDeclaration"})
    public void initWorkbookTable(final ModuleContext moduleContext)
    {
        try
        {
            LaboratoryManager.get().initWorkbooksForContainer(moduleContext.getUpgradeUser(), ContainerManager.getRoot());
        }
        catch (Exception e)
        {
            _log.error("Error upgrading laboratory module", e);
        }
    }

    /** called at 12.292-12.293 and 12.293-12.294 */
    @SuppressWarnings({"UnusedDeclaration"})
    public void migrateQuantityField(final ModuleContext moduleContext)
    {
        try
        {
            final TableInfo ti = LaboratorySchema.getInstance().getTable(LaboratorySchema.TABLE_SAMPLES);
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("quantity_string"), null, CompareType.NONBLANK);
            filter.addCondition(FieldKey.fromString("quantity"), null, CompareType.ISBLANK);

            TableSelector ts = new TableSelector(ti, PageFlowUtil.set("rowid", "quantity_string"), filter, null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    int rowId = rs.getInt("rowid");

                    String qs = rs.getString("quantity_string");
                    qs = StringUtils.trimToNull(qs);
                    if (qs == null)
                        return;

                    Double d = null;
                    try
                    {
                        d = Double.parseDouble(qs);
                    }
                    catch (NumberFormatException e)
                    {
                        //ignore
                    }

                    if (d != null)
                    {
                        Map<String, Object> map = new CaseInsensitiveHashMap<>();
                        map.put("quantity", d);

                        Table.update(moduleContext.getUpgradeUser(), ti, map, new Object[]{rowId});
                    }
                }
            });
        }
        catch (Exception e)
        {
            _log.error("Error upgrading laboratory module", e);
        }
    }

    /** called at 12.301-12.302 */
    @SuppressWarnings({"UnusedDeclaration"})
    public void updateWorkbookSequences(final ModuleContext moduleContext)
    {
        //find all parent containers with laboratory workbooks
        final TableInfo ti = LaboratorySchema.getInstance().getTable(LaboratorySchema.TABLE_WORKBOOKS);
        TableSelector ts = new TableSelector(ti);
        final Map<String, Integer> containerMap = new HashMap<>();
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Container c = ContainerManager.getForId(object.getString("parentcontainer"));
                if (c != null)
                {
                    //track the max workbook ID per container
                    Integer wbid = object.getInt("workbookid");
                    if (!containerMap.containsKey(c.getId()) || containerMap.get(c.getId()) < wbid)
                    {
                        containerMap.put(c.getId(), wbid);
                    }
                }
            }
        });

        //iterate containers.  if DBSsequence is behind the laboratory series, update the DB
        for (String id : containerMap.keySet())
        {
            Container c = ContainerManager.getForId(id);
            int current = DbSequenceManager.get(c, ContainerManager.WORKBOOK_DBSEQUENCE_NAME).current();
            if (current < containerMap.get(id))
            {
                _log.info("updating workbook Id for container: " + c.getName() + ", from: " + current + ", to: " + containerMap.get(id));
                while (current < containerMap.get(id))
                {
                    current = DbSequenceManager.get(c, ContainerManager.WORKBOOK_DBSEQUENCE_NAME).next();
                }
            }

            //note: if IDs are equal or if DbSequenceManager is ahead of laboratory (which should not occur) no action needed.  the lab module code will now defer to DbSequenceManager, so we simply skip the missing block
        }
    }
}
