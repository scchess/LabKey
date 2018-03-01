/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.labkey.targetedms.query;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.targetedms.TargetedMSManager;
import org.labkey.targetedms.TargetedMSSchema;

/**
 * User: vsharma
 * Date: 4/29/12
 * Time: 3:31 PM
 */
public class PrecursorChromatogramsTableInfo extends FilteredTable<TargetedMSSchema>
{
    private int _precursorId;

    public PrecursorChromatogramsTableInfo(TargetedMSSchema schema)
    {
        super(TargetedMSManager.getTableInfoPrecursorChromInfo(), schema);

        setName(TargetedMSSchema.TABLE_PRECURSOR_CHROM_INFO);

        //wrap all the columns
        wrapAllColumns(true);

        ColumnInfo peptideCol = getColumn("Id");
        peptideCol.setLabel("");

        peptideCol.setDisplayColumnFactory(new ChromatogramDisplayColumnFactory(getContainer(),
                                           ChromatogramDisplayColumnFactory.TYPE.PRECURSOR));
    }

    public void setPrecursorId(int precursorId)
    {
        _precursorId = precursorId;
    }

    public void addPrecursorFilter()
    {
        addCondition(new SimpleFilter(FieldKey.fromParts("PrecursorId"), _precursorId));
    }
}
