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
import org.labkey.api.collections.NamedObjectList;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.CoreSchema;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.util.SimpleNamedObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by davebradlee on 11/20/15
 */
public class AdjudicationUserTable extends FilteredTable<AdjudicationUserSchema>
{
    public static final String USERID = "UserId";
    public static final String ROLEID = "RoleId";

    public static final String FOLDERADMIN = "Folder Administrator";
    public static final String LABPERSONNEL = "Lab Personnel";
    public static final String ADJUDICATOR = "Adjudicator";
    public static final String INFECTIONMONITOR = "Infection Monitor";
    public static final String DATAREVIEWER = "Data Reviewer";
    public static final String TOBENOTIFIED = "To Be Notified";
    private static final Map<String, Integer> _adjudicationRoleMap = new HashMap<>();
    static
    {
        new TableSelector(AdjudicationSchema.getInstance().getSchema().getTable("AdjudicationRole")).forEachMap((map) ->
                _adjudicationRoleMap.put((String) map.get("Name"), (Integer) map.get("RowId")));
    }
    public static int getAdjudicationRole(String role)
    {
        return _adjudicationRoleMap.get(role);
    }

    public AdjudicationUserTable(TableInfo realTable, @NotNull AdjudicationUserSchema schema)
    {
        super(realTable, schema);
        addWrapColumn(getRealTable().getColumn("RowId")).setHidden(true);
        addWrapColumn(getRealTable().getColumn(USERID)).setFk(new LookupForeignKey("UserId", "Email")
        {
            public TableInfo getLookupTableInfo()
            {
                return CoreSchema.getInstance().getTableInfoUsers();
            }

            @Override
            public NamedObjectList getSelectList(RenderContext ctx)
            {
                final NamedObjectList newList = new NamedObjectList();
                String sql = "SELECT UserId AS VALUE, Email AS TITLE FROM core.Users ORDER BY Email";
                new SqlSelector(schema.getDbSchema(), sql).forEach(rs ->
                    newList.put(new SimpleNamedObject(rs.getString(1), rs.getString(2)))
                );
                return newList;
            }
        });
        addWrapColumn(getRealTable().getColumn(ROLEID));

        SQLFragment teamNumberSql = new SQLFragment();
        teamNumberSql.append("(SELECT atu.TeamNumber FROM ");
        teamNumberSql.append(AdjudicationSchema.getInstance().getTableInfoAdjudicationTeamUser(), "atu");
        teamNumberSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".RowId = atu.AdjudicationUserId)");
        ExprColumn teamNumberCol = new ExprColumn(this, "TeamNumber", teamNumberSql, JdbcType.INTEGER);
        teamNumberCol.setHidden(true);
        addColumn(teamNumberCol);

        addWrapColumn(getRealTable().getColumn("Container")).setHidden(true);

        setImportURL(AbstractTableInfo.LINK_DISABLER);

        List<FieldKey> defaultCols = new ArrayList<>();
        defaultCols.add(FieldKey.fromParts("RoleId", "Name"));
        defaultCols.add(FieldKey.fromParts("UserId", "Email"));
        defaultCols.add(FieldKey.fromParts("UserId", "Active"));
        setDefaultVisibleColumns(defaultCols);
    }

    @Override
    public boolean hasPermission(@NotNull UserPrincipal user, @NotNull Class<? extends Permission> perm)
    {
        return (getContainer().hasPermission(user, AdminPermission.class));
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new AdjudicationUserQueryUpdateService(this, this.getRealTable());
    }
}
