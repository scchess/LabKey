/*
 * Copyright (c) 2013-2014 LabKey Corporation
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

package org.labkey.microarray.query;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.ContainerForeignKey;
import org.labkey.api.data.DatabaseTableType;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.UserIdQueryForeignKey;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.view.ActionURL;

public class FeatureAnnotationSetTable { }
/*
public class FeatureAnnotationSetTable extends FilteredTable<MicroarrayUserSchema>
{
    public FeatureAnnotationSetTable(MicroarrayUserSchema schema)
    {
        super(MicroarrayUserSchema schema);

        ActionURL url = new ActionURL(GEOMicroarrayController.ShowFeatureAnnotationSetAction.class, _userSchema.getContainer());
        DetailsURL detailsURL = new DetailsURL(url, "rowId", FieldKey.fromParts("RowId"));
        detailsURL.setContainerContext(_userSchema.getContainer());

        addWrapColumn(_rootTable.getColumn("RowId")).setHidden(true);
        ColumnInfo nameCol = addWrapColumn(_rootTable.getColumn("Name"));
        nameCol.setURL(detailsURL);
        setDetailsURL(detailsURL);
        addWrapColumn(_rootTable.getColumn("Vendor"));
        ColumnInfo folderCol = wrapColumn("Folder", _rootTable.getColumn("Container"));
        addWrapColumn(_rootTable.getColumn("Created"));
        addWrapColumn(_rootTable.getColumn("CreatedBy"));
        addWrapColumn(_rootTable.getColumn("Modified"));
        addWrapColumn(_rootTable.getColumn("ModifiedBy"));
        getColumn("CreatedBy").setFk(new UserIdQueryForeignKey(_userSchema.getUser(), getContainer()));
        getColumn("ModifiedBy").setFk(new UserIdQueryForeignKey(_userSchema.getUser(), getContainer()));

        addColumn(ContainerForeignKey.initColumn(folderCol, schema));

        setPublicSchemaName(schema.getSchemaName());

    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        TableInfo table = getRealTable();
        if (table != null && table.getTableType() == DatabaseTableType.TABLE)
            return new DefaultQueryUpdateService(this, table);
        return null;
    }

    @Override
    public boolean hasPermission(UserPrincipal user, Class<? extends Permission> perm)
    {
        return _userSchema.getContainer().hasPermission(user, perm);
    }
}
*/
