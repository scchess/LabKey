/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
package org.labkey.adjudication;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.collections.NamedObject;
import org.labkey.api.collections.NamedObjectList;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.LookupColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.util.SimpleNamedObject;

/**
 * Created by davebradlee on 12/11/15
 */
public class SupportedKitsTable extends DefaultAdjudicationTable
{

    public SupportedKitsTable(TableInfo realTable, @NotNull AdjudicationUserSchema schema)
    {
        super(realTable, schema);
        addWrapColumn(getRealTable().getColumn("RowId")).setHidden(true);
        addWrapColumn(getRealTable().getColumn("KitCode")).setFk(new LookupForeignKey("Code")
        {
            @Override
            public TableInfo getLookupTableInfo()
            {
                return AdjudicationSchema.getInstance().getTableInfoKit();
            }

            @Override
            public ColumnInfo createLookupColumn(ColumnInfo parent, String displayFieldName)
            {
                if (null != displayFieldName)
                    return super.createLookupColumn(parent, displayFieldName);

                TableInfo tableInfo = getLookupTableInfo();
                ColumnInfo codeColumn = tableInfo.getColumn("Code");
                ColumnInfo descripColumn = tableInfo.getColumn("Description");
                SQLFragment sql = new SQLFragment(tableInfo.getSchema().getSqlDialect().concatenate(
                        "'('", codeColumn.getValueSql(ExprColumn.STR_TABLE_ALIAS).toDebugString(),
                        "') '", descripColumn.getValueSql(ExprColumn.STR_TABLE_ALIAS).toDebugString()));
                ColumnInfo expr = new ExprColumn(tableInfo, "Kit", sql, JdbcType.VARCHAR, codeColumn, descripColumn);
                return LookupColumn.create(parent, getPkColumn(tableInfo), expr, false);
            }

            @Override
            public NamedObjectList getSelectList(RenderContext ctx)
            {
                // Make list include the code, e.g. "(104) Roche ..."
                NamedObjectList list = super.getSelectList(ctx);
                final NamedObjectList newList = new NamedObjectList();
                for (NamedObject namedObject : list)
                {
                    if (namedObject instanceof SimpleNamedObject)
                    {
                        String newValue = "(" + namedObject.getName() + ") " + namedObject.getObject();
                        newList.put(new SimpleNamedObject(namedObject.getName(), newValue));
                    }
                    else
                    {
                        newList.put(namedObject);
                    }
                }
                return newList;
            }
        });
        addWrapColumn(getRealTable().getColumn("Container")).setHidden(true);

        setImportURL(AbstractTableInfo.LINK_DISABLER);
    }
}
