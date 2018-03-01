/*
 * Copyright (c) 2012 LabKey Corporation
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
package org.labkey.ldk.query;

import org.apache.commons.beanutils.ConversionException;
import org.apache.commons.beanutils.ConvertUtils;
import org.apache.commons.collections4.MultiValuedMap;
import org.apache.commons.collections4.multimap.ArrayListValuedHashMap;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.BuiltInButtonConfig;
import org.labkey.api.data.ButtonBarConfig;
import org.labkey.api.data.ButtonConfig;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SchemaTableInfo;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.UserDefinedButtonConfig;
import org.labkey.api.gwt.client.AuditBehaviorType;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.ldk.table.ButtonConfigFactory;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.study.assay.AssayResultTable;
import org.labkey.api.util.StringExpression;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 9/27/12
 * Time: 3:09 PM
 */
public class DefaultTableCustomizer implements TableCustomizer
{
    private static final String MORE_ACTIONS = "More Actions";

    private static final Logger _log = Logger.getLogger(TableCustomizer.class);
    private Settings _settings;

    public DefaultTableCustomizer()
    {
        this(new ArrayListValuedHashMap());
    }

    public DefaultTableCustomizer(MultiValuedMap props)
    {
        _settings = new Settings(props);
    }

    public void customize(TableInfo table)
    {
        if (table instanceof SchemaTableInfo)
            _log.error("Table customizer is being passed a SchemaTableInfo for: " + table.getPublicSchemaName() + "." + table.getPublicName());
        else if (table instanceof AbstractTableInfo)
            customizeAbstractTableInfo((AbstractTableInfo)table);
    }

    private void customizeAbstractTableInfo(AbstractTableInfo ti)
    {
        customizeEditUI(ti);
        setDetailsUrl(ti);

        ti.setAuditBehavior(_settings.getAuditMode());

        List<ButtonConfigFactory> buttons = LDKService.get().getQueryButtons(ti);
        customizeButtonBar(ti, buttons);

        //customize builtin columns
        BuiltInColumnsCustomizer colCustomizer = new BuiltInColumnsCustomizer();
        colCustomizer.setDisableFacetingForNumericCols(_settings.isDisableFacetingForNumericCols());
        colCustomizer.customize(ti);
    }

    private void setDetailsUrl(AbstractTableInfo ti)
    {
        if (!_settings.isOverrideDetailsUrl())
        {
            return;
        }

        String schemaName = ti.getUserSchema().getSchemaName();
        assert schemaName != null;

        String queryName = ti.getPublicName();
        assert queryName != null;

        List<String> keyFields = ti.getPkColumnNames();
        assert keyFields.size() > 0 : "No key fields found for the table: " + ti.getPublicSchemaName() + "." + ti.getPublicName();
        if (keyFields.size() != 1)
        {
            _log.error("Table: " + ti.getUserSchema().getSchemaName() + "." + ti.getPublicName() + " has more than 1 PK: " + StringUtils.join(keyFields, ";") + ", cannot apply custom links - please update the TableCustomizer properties");
            return;
        }

        String keyField = keyFields.get(0);
        StringExpression se = ti.getDetailsURL(null, ti.getUserSchema().getContainer());
        if (se == null || se.toString().contains("detailsQueryRow"))
        {
            ti.setDetailsURL(DetailsURL.fromString("/query/recordDetails.view?schemaName=" + schemaName + "&query.queryName=" + queryName + "&keyField=" + keyField + "&key=${" + keyField + "}"));
        }
    }

    private void customizeEditUI(AbstractTableInfo ti)
    {
        if (_settings.isDisableAllEditUI())
        {
            ti.setInsertURL(AbstractTableInfo.LINK_DISABLER);
            ti.setImportURL(AbstractTableInfo.LINK_DISABLER);
            ti.setDeleteURL(AbstractTableInfo.LINK_DISABLER);
        }
        else if (_settings.isSetEditLinkOverrides())
        {
            //otherwise apply custom urls
            String schemaName = ti.getUserSchema().getSchemaName();
            assert schemaName != null;

            String queryName = ti.getPublicName();
            assert queryName != null;

            List<String> keyFields = ti.getPkColumnNames();
            assert keyFields.size() > 0 : "No key fields found for the table: " + ti.getPublicSchemaName() + "." + ti.getPublicName();
            if (keyFields.size() != 1)
            {
                _log.error("Table: " + schemaName + "." + queryName + " has more than 1 PK: " + StringUtils.join(keyFields, ";") + ", cannot apply custom links - please update the TableCustomizer properties");
                return;
            }

            if (schemaName != null && queryName != null && keyFields.size() > 0)
            {
                String keyField = keyFields.get(0);
                if (!AbstractTableInfo.LINK_DISABLER_ACTION_URL.equals(ti.getImportDataURL(ti.getUserSchema().getContainer())))
                    ti.setImportURL(DetailsURL.fromString("/query/importData.view?schemaName=" + schemaName + "&query.queryName=" + queryName + "&keyField=" + keyField + "&bulkImport=true"));

                //Note: switch to menu button to mirror new UI, instead of using a single button
                if (!AbstractTableInfo.LINK_DISABLER_ACTION_URL.equals(ti.getInsertURL(ti.getUserSchema().getContainer())))
                    ti.setInsertURL(DetailsURL.fromString("/query/importData.view?schemaName=" + schemaName + "&query.queryName=" + queryName + "&keyField=" + keyField + "&bulkImport=false"));

                if (!AbstractTableInfo.LINK_DISABLER.equals(ti.getUpdateURL(null, ti.getUserSchema().getContainer())))
                    ti.setUpdateURL(DetailsURL.fromString("/ldk/manageRecord.view?schemaName=" + schemaName + "&query.queryName=" + queryName + "&keyField=" + keyField + "&key=${" + keyField + "}"));
            }
        }
    }

    public static void applyNaturalSort(AbstractTableInfo ti, String colName)
    {
        ColumnInfo col = ti.getColumn(FieldKey.fromString(colName));
        if (col == null)
            return;

        //only attempt to do this for strings
        if (!String.class.equals(col.getJavaClass()))
            throw new IllegalArgumentException("Natural sorting only supported on string columns");

        if (!LDKService.get().isNaturalizeInstalled())
        {
            _log.warn("Attempt to add natural sorting to a column when naturalize() has not been installed on this server");
            return;
        }

        //first add the sort col
        String name = colName + "_sortValue";
        ColumnInfo sortCol = ti.getColumn(name);
        if (sortCol != null)
        {
            // We need to swap out the placeholder version
            ti.removeColumn(sortCol);
        }

        if (!ti.getSqlDialect().isPostgreSQL() && !ti.getSqlDialect().isSqlServer())
        {
            throw new UnsupportedOperationException("naturalize() is only supported on Postgres and SqlServer");
        }

        SQLFragment sql = new SQLFragment("ldk.naturalize(").append(col.getValueSql(ExprColumn.STR_TABLE_ALIAS)).append(")");
        sortCol = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, col);
        sortCol.setHidden(true);
        sortCol.setLabel(col.getLabel() + " - Sort Field");
        ti.addColumn(sortCol);

        col.setSortFieldKeys(Arrays.asList(sortCol.getFieldKey()));
    }

    public static void appendCalculatedDateColumns(AbstractTableInfo ti, @Nullable String dateColName, @Nullable String enddateColName)
    {
        if (enddateColName != null)
        {
            appendEnddate(ti, enddateColName);
        }

        if (dateColName != null)
        {
            appendDateOnly(ti, dateColName);
        }
    }

    private static void appendEnddate(AbstractTableInfo ti, String sourceColName)
    {
        ColumnInfo sourceCol = ti.getColumn(sourceColName);
        if (sourceCol == null)
        {
            _log.error("Unable to find column: " + sourceColName + " on table " + ti.getSelectName());
            return;
        }

        String name = sourceCol.getName();
        if (ti.getColumn(name + "Coalesced") == null)
        {
            SQLFragment sql = new SQLFragment("CAST(COALESCE(" + ExprColumn.STR_TABLE_ALIAS + "." + sourceCol.getSelectName() + ", {fn curdate()}) as date)");
            ExprColumn col = new ExprColumn(ti, name + "Coalesced", sql, JdbcType.DATE);
            col.setCalculated(true);
            col.setUserEditable(false);
            col.setHidden(true);
            col.setLabel(col.getLabel() + ", Coalesced");

            if (sourceCol.getFormat() != null)
                col.setFormat(sourceCol.getFormat());

            ti.addColumn(col);
        }

        if (ti.getColumn(name + "timeCoalesced") == null)
        {
            SQLFragment sql = new SQLFragment("COALESCE(" + ExprColumn.STR_TABLE_ALIAS + "." + sourceCol.getSelectName() + ", {fn now()})");
            ExprColumn col = new ExprColumn(ti, name + "timeCoalesced", sql, JdbcType.DATE);
            col.setCalculated(true);
            col.setUserEditable(false);
            col.setHidden(true);
            col.setLabel(col.getLabel() + " - DateTime, Coalesced");
            col.setFormat("yyyy-MM-dd HH:mm");

            ti.addColumn(col);
        }
    }

    private static void appendDateOnly(AbstractTableInfo ti, String sourceColName)
    {
        ColumnInfo sourceCol = ti.getColumn(sourceColName);
        if (sourceCol == null)
        {
            _log.error("Unable to find column: " + sourceColName + " on table " + ti.getName());
            return;
        }

        String name = sourceCol.getName().equals("date") ? "dateOnly" : sourceCol.getName() + "DatePart";
        if (ti.getColumn(name) == null)
        {
            SQLFragment sql = new SQLFragment(ti.getSqlDialect().getDateTimeToDateCast(ExprColumn.STR_TABLE_ALIAS + "." + sourceCol.getSelectName()));
            ExprColumn col = new ExprColumn(ti, name, sql, JdbcType.DATE);
            col.setCalculated(true);
            col.setUserEditable(false);
            col.setHidden(true);
            col.setLabel(col.getLabel() + " - Date Only");
            ti.addColumn(col);
        }
    }

    public static void customizeButtonBar(AbstractTableInfo ti, List<ButtonConfigFactory> buttons)
    {
        UserSchema us = ti.getUserSchema();
        if (us == null)
            return;

        ButtonBarConfig cfg = ti.getButtonBarConfig();
        if (cfg == null)
        {
            cfg = new ButtonBarConfig(new JSONObject());
            cfg.setIncludeStandardButtons(true);
        }

        //ensure client dependencies
        Set<String> scripts = new LinkedHashSet<>();
        String[] existingScripts = cfg.getScriptIncludes();
        if (existingScripts != null)
        {
            for (String s : existingScripts)
            {
                scripts.add(s);
            }
        }

        boolean hasMoreActions = configureMoreActionsBtn(ti, buttons, cfg, scripts);

        cfg.setScriptIncludes(scripts.toArray(new String[scripts.size()]));
        if (hasMoreActions)
            cfg.setAlwaysShowRecordSelectors(true);

        ti.setButtonBarConfig(cfg);
    }

    private static String getExpectedImportBtnName(TableInfo ti)
    {
        if (ti instanceof AssayResultTable)
        {
            return "Import Data";
        }
        else if (ti.getInsertURL(ti.getUserSchema().getContainer()) != AbstractTableInfo.LINK_DISABLER_ACTION_URL && ti.getImportDataURL(ti.getUserSchema().getContainer()) != AbstractTableInfo.LINK_DISABLER_ACTION_URL)
        {
            return "Insert";
        }

        return "Import Bulk Data";
    }

    private static boolean hasImportDataBtn(ButtonBarConfig cfg, TableInfo ti)
    {
        if (cfg.getItems() == null)
            return false;

        String expectedName = getExpectedImportBtnName(ti);
        for (ButtonConfig bc : cfg.getItems())
        {
            if (bc instanceof BuiltInButtonConfig)
            {
                if (((BuiltInButtonConfig)bc).getOriginalCaption().equals(expectedName))
                {
                    return true;
                }
            }
            else if (bc instanceof UserDefinedButtonConfig)
            {
                if (((UserDefinedButtonConfig)bc).getText().equals(expectedName))
                {
                    return true;
                }
            }
        }

        return false;
    }

    private static boolean configureMoreActionsBtn(TableInfo ti, List<ButtonConfigFactory> buttons, ButtonBarConfig cfg, Set<String> scripts)
    {
        if (buttons == null || buttons.isEmpty())
        {
            return false;
        }

        List<ButtonConfig> existingBtns = cfg.getItems();
        UserDefinedButtonConfig moreActionsBtn = null;
        if (existingBtns != null)
        {
            for (ButtonConfig btn : existingBtns)
            {
                if (btn instanceof UserDefinedButtonConfig)
                {
                    UserDefinedButtonConfig ub = (UserDefinedButtonConfig)btn;
                    if (MORE_ACTIONS.equals(ub.getText()))
                    {
                        moreActionsBtn = ub;
                        break;
                    }
                }
            }
        }

        if (moreActionsBtn == null)
        {
            //abort if there are no custom buttons
            if (buttons.size() == 0)
                return false;

            moreActionsBtn = new UserDefinedButtonConfig();
            moreActionsBtn.setText(MORE_ACTIONS);
            moreActionsBtn.setIconCls("ellipsis-h");
            moreActionsBtn.setInsertPosition(-1);
            existingBtns.add(moreActionsBtn);
            cfg.setItems(existingBtns);
        }

        List<NavTree> menuItems = new ArrayList<NavTree>();
        if (moreActionsBtn.getMenuItems() != null)
            menuItems.addAll(moreActionsBtn.getMenuItems());

        //create map of existing item names
        Map<String, NavTree> btnNameMap = new HashMap<String, NavTree>();
        for (NavTree item : menuItems)
        {
            btnNameMap.put(item.getText(), item);
        }

        for (ButtonConfigFactory fact : buttons)
        {
            NavTree newButton = fact.create(ti);
            if (!btnNameMap.containsKey(newButton.getText()))
            {
                btnNameMap.put(newButton.getText(), newButton);
                menuItems.add(newButton);

                for (ClientDependency cd : fact.getClientDependencies(ti.getUserSchema().getContainer(), ti.getUserSchema().getUser()))
                {
                    scripts.add(cd.getScriptString());
                }
            }
        }

        moreActionsBtn.setMenuItems(menuItems);

        return true;
    }

    public static class Settings
    {
        private Map<PROPERIES, Object> propertyMap;

        public static enum PROPERIES
        {
            disableAllEditUI(Boolean.class, false),
            setEditLinkOverrides(Boolean.class, true),
            auditMode(String.class, AuditBehaviorType.DETAILED.name()),
            disableFacetingForNumericCols(Boolean.class, true),
            overrideDetailsUrl(Boolean.class, true);

            private Class _clazz;
            private Object _defaultVal;

            PROPERIES(Class clazz, Object defaultVal)
            {
                _clazz = clazz;
                _defaultVal = defaultVal;
            }

            public Class getConvertClass()
            {
                return _clazz;
            }

            public Object getDefaultVal()
            {
                return _defaultVal;
            }
        }

        public Settings(MultiValuedMap<String, String> props)
        {
            propertyMap = new HashMap<>();
            for (PROPERIES p : PROPERIES.values())
            {
                if (props.get(p.name()) != null)
                {
                    if (props.get(p.name()).size() > 1)
                    {
                        _log.error("Multiple values provided for property: " + p.name() +  ", values: " + StringUtils.join(props.get(p.name()), ";"));
                    }

                    try
                    {
                        Collection<String> c = props.get(p.name());
                        if (c.size() > 1)
                        {
                            _log.error("More than one value supplied for property: " + p.name() + " in table XML, values: " + StringUtils.join(c, ";"));
                        }

                        if (!c.isEmpty())
                        {
                            propertyMap.put(p, ConvertUtils.convert(c.iterator().next(), p.getConvertClass()));
                        }
                    }
                    catch (ConversionException e)
                    {
                        _log.error("Unable to type convert property " + p.name() +  ", value: " + props.get(p.name()).iterator().next());
                    }
                }
            }

        }

        private Object getProperty(PROPERIES p)
        {
            return (propertyMap.get(p) == null ? p.getDefaultVal() : propertyMap.get(p));
        }

        public boolean isDisableAllEditUI()
        {
            return (boolean)getProperty(PROPERIES.disableAllEditUI);
        }

        public boolean isSetEditLinkOverrides()
        {
            return (boolean)getProperty(PROPERIES.setEditLinkOverrides);
        }

        public AuditBehaviorType getAuditMode()
        {
            try
            {
                String auditMode = (String) getProperty(PROPERIES.auditMode);
                return AuditBehaviorType.valueOf(auditMode);
            }
            catch (IllegalArgumentException e)
            {
                _log.error("Unable to parse auditMode in TableCustomizer: " + getProperty(PROPERIES.auditMode));
            }

            return AuditBehaviorType.DETAILED;
        }

        public boolean isDisableFacetingForNumericCols()
        {
            return (boolean)getProperty(PROPERIES.disableFacetingForNumericCols);
        }

        public boolean isOverrideDetailsUrl()
        {
            return (boolean)getProperty(PROPERIES.overrideDetailsUrl);
        }
    }
}
