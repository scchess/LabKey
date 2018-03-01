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

package org.labkey.cnprc_ehr.table;

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ehr.table.DurationColumn;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.UserSchema;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;


public class CNPRC_EHRCustomizer extends AbstractTableCustomizer
{
    @Override
    public void customize(TableInfo tableInfo)
    {
        doTableSpecificCustomizations((AbstractTableInfo) tableInfo);
    }

    public void doTableSpecificCustomizations(AbstractTableInfo ti)
    {
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        if (matches(ti, "study", "Animal"))
        {
            customizeAnimalTable(ti);
        }
        else if (matches(ti, "study", "RelocationHistory"))
        {
            customizeRelocationHistoryQuery(ti, dateTimeFormatter);
        }
        else if (matches(ti, "study", "LocationReport"))
        {
            customizeLocationReportQuery(ti, dateTimeFormatter);
        }
        else if (matches(ti, "study", "WeightsTbAndBodyCondition"))
        {
            customizeWeightsTbAndBodyConditionQuery(ti, dateTimeFormatter);
        }
        else if (matches(ti, "study", "Clinical Observations") || matches(ti, "study", "clinical_observations"))
        {
            customizeClinicalObservations(ti);
        }
        else if (matches(ti, "ehr_lookups", "snomed"))
        {
            customizeSnomedLookupTable(ti);
        }
    }

    private void customizeSnomedLookupTable(AbstractTableInfo ti)
    {
        ColumnInfo categoryCol = ti.getColumn("sortOrder");
        if (categoryCol == null)
        {
            // Requested CNPRC custom sort ordering for snomed codes based on prefix
            SQLFragment sql = new SQLFragment("CASE ");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code IS NULL THEN CAST(NULL AS INT) \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'P-%' THEN 1 \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'T-%' THEN 2 \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'M-%' THEN 3 \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'E-%' THEN 4 \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'F-%' THEN 5 \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'D-%' THEN 6 \n");
            sql.append(" WHEN ").append(ExprColumn.STR_TABLE_ALIAS).append(".Code LIKE 'J-%' THEN 7 \n");
            sql.append(" ELSE 8 END \n");
            categoryCol = new ExprColumn(ti, "sortOrder", sql, JdbcType.INTEGER, ti.getColumn("code"));
            categoryCol.setHidden(true);
            ti.addColumn(categoryCol);
        }
    }

    private void customizeClinicalObservations(AbstractTableInfo ti)
    {
        ColumnInfo categoryCol = ti.getColumn("category");
        if (categoryCol != null)
        {
            UserSchema us = getUserSchema(ti, "ehr");
            if (us != null)
            {
                categoryCol.setFk(new QueryForeignKey(us, null, "observation_types", "value", "value", true));
            }
        }
    }

    private void customizeAnimalTable(AbstractTableInfo ds)
    {
        UserSchema us = getUserSchema(ds, "study");

        if (us == null)
        {
            return;
        }

        if (ds.getColumn("Arrival") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "Arrival", "arrival", "Id", "Id");
            col.setLabel("Arrival");
            col.setDescription("Arrival");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsAssignmentsPast") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsAssignmentsPast", "DemographicsAssignmentsPast", "Id", "Id");
            col.setLabel("Past Assignments");
            col.setDescription("Past Project Assignments");
            ds.addColumn(col);
        }

        if (ds.getColumn("BreedingRoster") == null)
        {
            ColumnInfo col = getWrappedCol(getUserSchema(ds, "cnprc_ehr"), ds, "BreedingRoster", "breedingRoster", "Id", "animalId");
            col.setLabel("Breeding Roster");
            col.setDescription("Breeding Roster");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeFlagList") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "activeFlagList", "demographicsActiveFlags", "Id", "Id");
            col.setLabel("Active Flags");
            col.setDescription("This provides a column summarizing all active flags per animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("cageViolation") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "cageViolation", "CageViolations", "Id", "Id");
            col.setLabel("Cage Violations");
            col.setDescription("Cage violations");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActiveColony") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActiveColony", "DemographicsActiveColony", "Id", "Id");
            col.setLabel("Current Colony");
            col.setDescription("Returns one record per participant with the colony assignment having no Release Date");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActiveBreedingGroup") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActiveBreedingGroup", "DemographicsActiveBreedingGroup", "Id", "Id");
            col.setLabel("Current Breeding Group");
            col.setDescription("Returns one record per participant with the breeding group assignment having no Release Date");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActiveLongTermCases") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActiveLongTermCases", "demographicsActiveLongTermCases", "Id", "Id");
            col.setLabel("Current Long Term Outpatient Cases");
            col.setDescription("Returns one record per participant with a long term outpatient case assignment having no Release Date");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActiveAssignment") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActiveAssignment", "DemographicsActiveAssignment", "Id", "Id");
            col.setLabel("Current Assignments");
            col.setDescription("Returns one record per participant with Primary and list of Secondary projects");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActivePairing") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActivePairing", "DemographicsActivePairing", "Id", "Id");
            col.setLabel("Active Pairing");
            col.setDescription("Returns the participant's active Pairing");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActivePairingCode") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActivePairingCode", "DemographicsActivePairingCode", "Id", "Id");
            col.setLabel("Active Pairing Code");
            col.setDescription("Returns the participant's active Pairing Code");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActivePayor") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActivePayor", "DemographicsActivePayor", "Id", "Id");
            col.setLabel("Current Payor");
            col.setDescription("Returns one record per participant with currently assigned payor");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActivePregnancy") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActivePregnancy", "DemographicsActivePregnancy", "Id", "Id");
            col.setLabel("Current Pregnancy");
            col.setDescription("Returns one record per currently pregnant participant");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsBirthPlace") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsBirthPlace", "DemographicsBirthPlace", "Id", "Id");
            col.setLabel("Birth Place");
            col.setDescription("Returns the participant's Arrival source or Birth Room and Cage");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsHolds") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsHolds", "DemographicsHolds", "Id", "Id");
            col.setLabel("Holds");
            col.setDescription("Returns the participant's active flags having HOLD in the title");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsMostRecentBodyConditionScore") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsMostRecentBodyConditionScore", "DemographicsMostRecentBodyConditionScore", "Id", "Id");
            col.setLabel("Most Recent BCS");
            col.setDescription("Returns the participant's most recent body condition score");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsMostRecentSerum") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsMostRecentSerum", "DemographicsMostRecentSerum", "Id", "Id");
            col.setLabel("Current Serum");
            col.setDescription("Returns the participant's most recent serum sample date and the days since it was taken");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsMostRecentTB") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsMostRecentTB", "DemographicsMostRecentTB", "Id", "Id");
            col.setLabel("Current TB");
            col.setDescription("Returns the participant's most recent TB date and the days since it was taken");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsMostRecentTetanus") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsMostRecentTetanus", "DemographicsMostRecentTetanus", "Id", "Id");
            col.setLabel("Current Tetanus");
            col.setDescription("Returns the participant's most recent Tetanus date and the days since it was taken");
            ds.addColumn(col);
        }

        if (ds.getColumn("flagList") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "flagList", "demographicsFlags", "Id", "Id");
            col.setLabel("Flags");
            col.setDescription("This provides a columm summarizing all flags per animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("HybridReportFlags") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "HybridReportFlags", "HybridReportFlags", "Id", "Id");
            col.setLabel("HybridReportFlags");
            col.setDescription("Supports presenting flags in Hybrid Report");
            ds.addColumn(col);
        }

        if (ds.getColumn("HomeLocation") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "HomeLocation", "Home Location", "Id", "Id");
            col.setLabel("Home Location");
            col.setDescription("Home Location");
            ds.addColumn(col);
        }

        if (ds.getColumn("LabworkResults") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "LabworkResults", "labworkResults", "Id", "Id");
            col.setLabel("Labwork Results");
            col.setDescription("Labwork Results");
            ds.addColumn(col);
        }

        if (ds.getColumn("NcRoundup") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "NcRoundup", "NcRoundup", "Id", "Id");
            col.setLabel("Nc Roundup");
            col.setDescription("Nc Roundup");
            ds.addColumn(col);
        }


        if (ds.getColumn("parents") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "parents", "demographicsParents", "Id", "Id");
            col.setLabel("Parents");
            col.setDescription("Shows the known parents of each animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("Gestation") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "Gestation", "Gestation", "Id", "Id");
            col.setLabel("Gestation");
            col.setDescription("Gestation");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsSnomed") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsSnomed", "DemographicsSnomed", "Id", "Id");
            col.setLabel("SNOMED Animals Conceptions Codes");
            col.setDescription("A concatenation of the participant's SNOMED codes");
            ds.addColumn(col);
        }

        if (ds.getColumn("TB Report") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "TB Report", "TB Report", "Id", "Id");
            col.setLabel("TB Report");
            col.setDescription("TB Report");
            ds.addColumn(col);
        }

        if (ds.getColumn("WeightEncounter") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "WeightEncounter", "WeightEncounter", "Id", "Id");
            col.setLabel("Weight Encounter");
            col.setDescription("Weight Encounter");
            ds.addColumn(col);
        }

        if (ds.getColumn("necropsyPerformed") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "NecropsyPerformed", "necropsyPerformed", "Id", "Id");
            col.setLabel("Necropsy Performed?");
            col.setDescription("Necropsy Performed - Yes or No");
            ds.addColumn(col);
        }

        if (ds.getColumn("ProjectAssignmentHistory") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "ProjectAssignmentHistory", "ProjectAssignmentHistory", "Id", "Id");
            col.setLabel("Project Assignment History");
            col.setDescription("Project Assignment History");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsActiveCases") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsActiveCases", "DemographicsActiveCases", "Id", "Id");
            col.setLabel("Active Cases");
            col.setDescription("Active Cases");
            ds.addColumn(col);
        }

        if (ds.getColumn("DemographicsUtilization") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "DemographicsUtilization", "DemographicsUtilization", "Id", "Id");
            col.setLabel("Utilization");
            col.setDescription("Utilization");
            ds.addColumn(col);
        }

        if (ds.getColumn("demographicsBirthInfo") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "demographicsBirthInfo", "demographicsBirthInfo", "Id", "Id");
            col.setLabel("DemographicsBirthInfo");
            col.setDescription("Birth-Conception Related Info");
            ds.addColumn(col);
        }

        if (ds.getColumn("ageDates") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "ageDates", "ageDates", "Id", "Id");
            col.setLabel("Age Dates");
            col.setDescription("Dates to calculate housing intervals");
            ds.addColumn(col);
        }
    }

    private void customizeRelocationHistoryQuery(AbstractTableInfo ti, DateTimeFormatter dateTimeFormatter)
    {
        String colName = "timeAtLocation";

        if (ti.getColumn(colName) == null)
        {
            WrappedColumn timeAtLocationCol = new WrappedColumn(ti.getColumn("date"), colName);
            timeAtLocationCol.setDisplayColumnFactory(colInfo -> new DurationColumn(colInfo, "date", "endDate", "yy:MM:dd"));

            ti.addColumn(timeAtLocationCol);
        }

        ColumnInfo columnInfo = ti.getColumn("location");
        String onDateParamName = "onDate";

        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.location~eq=${location}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }

        columnInfo = ti.getColumn("room");
        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.room~eq=${room}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }

        columnInfo = ti.getColumn("cage");
        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.room~eq=${room}" +
                    "&query.cage~eq=${cage}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }
    }

    private void customizeLocationReportQuery(AbstractTableInfo ti, DateTimeFormatter dateTimeFormatter)
    {
        ColumnInfo columnInfo = ti.getColumn("location");
        String onDateParamName = "onDate";

        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.location~eq=${location}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }

        columnInfo = ti.getColumn("room");
        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.room~eq=${room}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }

        columnInfo = ti.getColumn("cage");
        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.room~eq=${room}" +
                    "&query.cage~eq=${cage}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }

        final String colName2 = "birth";
        String colLabel = "age";
        if (ti.getColumn(colLabel) == null)
        {
            WrappedColumn ageCol = new WrappedColumn(ti.getColumn(colName2), colLabel);
            ageCol.setDisplayColumnFactory(colInfo -> new DurationColumn(colInfo, colName2, "deathOrOnDate", "yy:MM:dd"));

            ti.addColumn(ageCol);
        }
    }

    private void customizeWeightsTbAndBodyConditionQuery(AbstractTableInfo ti, DateTimeFormatter dateTimeFormatter)
    {
        ColumnInfo columnInfo = ti.getColumn("roomAtTime");
        String onDateParamName = "onDate";

        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.room~eq=${roomAtTime}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }

        columnInfo = ti.getColumn("cageAtTime");
        if (columnInfo != null)
        {
            columnInfo.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study" +
                    "&query.queryName=LocationReport" +
                    "&query.room~eq=${roomAtTime}" +
                    "&query.cage~eq=${cageAtTime}" +
                    "&query.param." + onDateParamName + "=" + LocalDateTime.now().format(dateTimeFormatter)));
        }
    }

    private ColumnInfo getWrappedCol(UserSchema us, AbstractTableInfo ds, String name, String queryName, String colName, String targetCol)
    {

        WrappedColumn col = new WrappedColumn(ds.getColumn(colName), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new QueryForeignKey(us, null, queryName, targetCol, targetCol));

        return col;
    }
}
