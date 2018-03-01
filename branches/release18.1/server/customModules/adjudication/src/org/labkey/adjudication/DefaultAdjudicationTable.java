/*
 * Copyright (c) 2017 LabKey Corporation
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
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.Permission;

public class DefaultAdjudicationTable extends FilteredTable<AdjudicationUserSchema>
{
    public DefaultAdjudicationTable(TableInfo table, @NotNull AdjudicationUserSchema userSchema)
    {
        super(table, userSchema);
    }

    public DefaultAdjudicationTable(TableInfo table, @NotNull AdjudicationUserSchema userSchema, boolean wrapAllColumns, boolean disableInsert)
    {
        super(table, userSchema);

        if (wrapAllColumns)
            wrapAllColumns(true);

        if (disableInsert)
        {
            setInsertURL(AbstractTableInfo.LINK_DISABLER);
            setImportURL(AbstractTableInfo.LINK_DISABLER);
        }
    }

    @Override
    public boolean hasPermission(@NotNull UserPrincipal user, @NotNull Class<? extends Permission> perm)
    {
        return (getContainer().hasPermission(user, AdminPermission.class));
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new DefaultQueryUpdateService(this, this.getRealTable());
    }
}
