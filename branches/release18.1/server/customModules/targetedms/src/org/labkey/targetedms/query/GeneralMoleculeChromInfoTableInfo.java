/*
 * Copyright (c) 2016 LabKey Corporation
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

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.view.ActionURL;
import org.labkey.targetedms.TargetedMSController;
import org.labkey.targetedms.TargetedMSSchema;

import java.util.ArrayList;

public class GeneralMoleculeChromInfoTableInfo extends TargetedMSTable
{
    public GeneralMoleculeChromInfoTableInfo(TableInfo table, TargetedMSSchema schema, SQLFragment joinSQL, String name)
    {
        super(table, schema, joinSQL);
        setName(name);

        // Add a link to view the chromatogram an individual transition
        setDetailsURL(new DetailsURL(new ActionURL(TargetedMSController.GeneralMoleculeChromatogramChartAction.class, getContainer()), "id", FieldKey.fromParts("Id")));

        ColumnInfo generalMoleculeId = getColumn("GeneralMoleculeId");
        generalMoleculeId.setFk(new TargetedMSForeignKey(getUserSchema(), TargetedMSSchema.TABLE_PEPTIDE));
        generalMoleculeId.setHidden(true);

        ColumnInfo peptideId = wrapColumn("PeptideId", getRealTable().getColumn(generalMoleculeId.getFieldKey()));
        peptideId.setFk(new TargetedMSForeignKey(getUserSchema(), TargetedMSSchema.TABLE_PEPTIDE));
        addColumn(peptideId);

        ColumnInfo moleculeId = wrapColumn("MoleculeId", getRealTable().getColumn(generalMoleculeId.getFieldKey()));
        moleculeId.setFk(new TargetedMSForeignKey(getUserSchema(), TargetedMSSchema.TABLE_MOLECULE));
        addColumn(moleculeId);

        //only display a subset of the columns by default
        ArrayList<FieldKey> visibleColumns = new ArrayList<>();
        visibleColumns.add(FieldKey.fromParts("PeptideId"));
        visibleColumns.add(FieldKey.fromParts("MoleculeId"));
        visibleColumns.add(FieldKey.fromParts("SampleFileId"));
        visibleColumns.add(FieldKey.fromParts("PeakCountRatio"));
        visibleColumns.add(FieldKey.fromParts("RetentionTime"));
        setDefaultVisibleColumns(visibleColumns);
    }
}