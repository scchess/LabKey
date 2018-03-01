/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
import org.labkey.api.data.AbstractForeignKey;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.util.SimpleNamedObject;
import org.labkey.api.util.StringExpression;

public class AdjudicationTeamUserTable extends FilteredTable<AdjudicationUserSchema>
{
    public static final String ADJUDICATIONUSERID = "AdjudicationUserId";
    public static final String TEAMNUMBER = "TeamNumber";
    public static final String NOTIFY = "Notify";


    public AdjudicationTeamUserTable(TableInfo realTable, @NotNull AdjudicationUserSchema schema)
    {
        super(realTable, schema);
        addWrapColumn(getRealTable().getColumn("RowId")).setHidden(true);
        addWrapColumn(getRealTable().getColumn(ADJUDICATIONUSERID)).setFk(new LookupForeignKey("RowId", "UserId")
        {
            public TableInfo getLookupTableInfo()
            {
                return AdjudicationSchema.getInstance().getTableInfoAdjudicationUser();
            }
        });

        ColumnInfo teamNumberColumn = addWrapColumn(getRealTable().getColumn(TEAMNUMBER));
        teamNumberColumn.setFk(new TeamForeignKey(getContainer()));
        teamNumberColumn.setInputType("select");

        addWrapColumn(getRealTable().getColumn("Notify"));
        addWrapColumn(getRealTable().getColumn("Container")).setHidden(true);

        setImportURL(AbstractTableInfo.LINK_DISABLER);
    }

    @Override
    public boolean hasPermission(@NotNull UserPrincipal user, @NotNull Class<? extends Permission> perm)
    {
        return (getContainer().hasPermission(user, AdminPermission.class));
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new AdjudicationTeamUserQueryUpdateService(this, this.getRealTable());
    }

    private class TeamForeignKey extends AbstractForeignKey
    {
        NamedObjectList _list = new NamedObjectList();

        TeamForeignKey(Container c)
        {
            int maxTeamMemberCount = AdjudicationManager.get().getNumberOfAdjudicatorTeams(c);
            for (int i = 1; i <= maxTeamMemberCount; i++)
                _list.put(new SimpleNamedObject("" + i, i));
        }

        @Override
        public ColumnInfo createLookupColumn(ColumnInfo parent, String displayField)
        {
            return null;
        }

        @Override
        public TableInfo getLookupTableInfo()
        {
            return null;
        }

        @Override
        public StringExpression getURL(ColumnInfo parent)
        {
            return null;
        }

        @Override
        public NamedObjectList getSelectList(RenderContext ctx)
        {
            return _list;
        }
    }
}
