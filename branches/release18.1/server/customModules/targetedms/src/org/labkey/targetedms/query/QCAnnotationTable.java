/*
 * Copyright (c) 2014 LabKey Corporation
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
package org.labkey.targetedms.query;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.ContainerForeignKey;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.Permission;
import org.labkey.targetedms.TargetedMSManager;
import org.labkey.targetedms.TargetedMSSchema;

/**
* Created by: jeckels
* Date: 12/7/14
*/
public class QCAnnotationTable extends FilteredTable<TargetedMSSchema>
{
    public QCAnnotationTable(TargetedMSSchema schema)
    {
        super(TargetedMSManager.getTableInfoQCAnnotation(), schema);

        wrapAllColumns(true);
        getColumn("Container").setFk(new ContainerForeignKey(schema));
        getColumn("QCAnnotationTypeId").setFk(new QueryForeignKey(schema, null, TargetedMSSchema.TABLE_QC_ANNOTATION_TYPE, "Id", "Name")
        {
            @Override
            public TableInfo getLookupTableInfo()
            {
                // Tweak the container filter based on the scoping rules for annotation types
                FilteredTable result = (FilteredTable) super.getLookupTableInfo();
                result.setContainerFilter(new ContainerFilter.CurrentPlusProjectAndShared(getUserSchema().getUser()));
                return result;
            }
        });
    }

    @Override
    public boolean hasPermission(@NotNull UserPrincipal user, @NotNull Class<? extends Permission> perm)
    {
        return getContainer().hasPermission(user, perm);
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new DefaultQueryUpdateService(this, getRealTable());
    }
}
