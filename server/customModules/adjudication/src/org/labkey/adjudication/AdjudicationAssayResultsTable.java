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

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.view.ActionURL;

/**
 * Created by davebradlee on 10/7/16.
 */
public class AdjudicationAssayResultsTable extends DefaultAdjudicationTable
{
    public AdjudicationAssayResultsTable(AdjudicationUserSchema schema, TableInfo realTable)
    {
        super(realTable, schema);
        realTable.getColumns()
                   .forEach(col -> {
                       ColumnInfo w = addWrapColumn(col);
                       w.setHidden(col.isHidden());
                   });
        setTitle("Assay Results");
    }

    @Override
    public ActionURL getInsertURL(Container container)
    {
        return AbstractTableInfo.LINK_DISABLER_ACTION_URL;
    }

    @Override
    public ActionURL getImportDataURL(Container container)
    {
        return AbstractTableInfo.LINK_DISABLER_ACTION_URL;
    }

}
