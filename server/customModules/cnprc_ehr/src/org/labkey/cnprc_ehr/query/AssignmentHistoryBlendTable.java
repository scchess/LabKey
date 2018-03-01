package org.labkey.cnprc_ehr.query;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.VirtualTable;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.UserSchema;
import org.labkey.api.study.Dataset;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;
import org.labkey.cnprc_ehr.CNPRC_EHRSchema;

public class AssignmentHistoryBlendTable extends VirtualTable
{
    public AssignmentHistoryBlendTable(UserSchema userSchema)
    {
        super(DbSchema.get("studydataset", DbSchemaType.Provisioned), CNPRC_EHRSchema.ASSIGNMENT_HISTORY_BLEND, userSchema);
        setupColumns();
    }

    @Override @NotNull
    public SQLFragment getFromSQL()
    {
        String datasetSchema = "studydataset.";
        String assignment = datasetSchema + getDatasetTableName("assignment");
        String payor_assignments = datasetSchema + getDatasetTableName("payor_assignments");
        String colony_assignments = datasetSchema + getDatasetTableName("colony_assignments");
        String breedinggroupassignments = datasetSchema + getDatasetTableName("breedinggroupassignments");

        SQLFragment sql = new SQLFragment();
        sql.append ("SELECT \n" +
                "      id,\n" +
                "      date as assigned,\n" +
                "      coalesce(lead(date) OVER (PARTITION BY id ORDER BY date), release_date) AS released,\n" +
                "      payorId,\n" +
                "      primaryProject,\n" +
                "      secondaryProjects,\n" +
                "      colonyCode,\n" +
                "      groupCode\n" +
                "    FROM (\n" +
                "\n" +
                "SELECT \n" +
                "            sub.id, \n" +
                "            sub.date,\n" +
                "            (CASE \n" +
                "                WHEN\n" +
                "                    payor.enddate > prim.enddate AND payor.enddate > brgroup.enddate AND payor.enddate > colony.enddate THEN payor.enddate\n" +
                "                WHEN\n" +
                "                    prim.enddate > brgroup.enddate AND prim.enddate > colony.enddate THEN prim.enddate\n" +
                "                WHEN\n" +
                "                    brgroup.enddate > colony.enddate THEN brgroup.enddate\n" +
                "                ELSE\n" +
                "                    colony.enddate\n" +
                "                END\n" +
                "            ) AS release_date,\n" +
                "\t\t\t(SELECT max(payor_id)\n" +
                "\t\t\t  FROM " + payor_assignments + " pyrassmnt\n" +
                "\t\t\t  WHERE pyrassmnt.participantid = sub.id AND pyrassmnt.date <= sub.date AND\n" +
                "\t\t\t\t\t(pyrassmnt.enddate > sub.date OR pyrassmnt.enddate IS NULL)\n" +
                "\t\t\t  GROUP BY pyrassmnt.participantid) payorId,\n" +
                "\t\t\t (SELECT max(projectCode)\n" +
                "\t\t\t  FROM " + assignment + " assmnt\n" +
                "\t\t\t  WHERE assmnt.participantid = sub.id AND assmnt.date <= sub.date AND (assmnt.enddate > sub.date OR assmnt.enddate IS NULL) AND\n" +
                "\t\t\t\t\tassmnt.assignmentStatus = 'P'\n" +
                "\t\t\t  GROUP BY assmnt.participantid)    primaryProject,\n" +
                "\t\t\t (SELECT core.GROUP_CONCAT_D(projectCode, ',')\n" +
                "\t\t\t  FROM " + assignment + " assmnt\n" +
                "\t\t\t  WHERE assmnt.participantid = sub.id AND assmnt.date <= sub.date AND (assmnt.enddate > sub.date OR assmnt.enddate IS NULL) AND\n" +
                "\t\t\t\t\tassmnt.assignmentStatus = 'S'\n" +
                "\t\t\t  GROUP BY assmnt.participantid)    secondaryProjects,\n" +
                "\t\t\t (SELECT max(colonyCode)\n" +
                "\t\t\t  FROM " + colony_assignments + " colassmnt\n" +
                "\t\t\t  WHERE colassmnt.participantid = sub.id\n" +
                "\t\t\t\t\tAND colassmnt.date <= sub.date AND\n" +
                "\t\t\t\t\t(colassmnt.enddate > sub.date OR colassmnt.enddate IS NULL)\n" +
                "\t\t\t  GROUP BY colassmnt.participantid) colonyCode,\n" +
                "\t\t\t (SELECT max(groupCode)\n" +
                "\t\t\t  FROM " + breedinggroupassignments + " bgassmnt\n" +
                "\t\t\t  WHERE\n" +
                "\t\t\t\tbgassmnt.participantid = sub.id AND bgassmnt.date <= sub.date AND (bgassmnt.enddate > sub.date OR bgassmnt.enddate IS NULL)\n" +
                "\t\t\t  GROUP BY bgassmnt.participantid)  groupCode,\n" +
                "            coalesce(sec.enddate, getdate()) AS sec_release_date\n" +
                "            FROM\n" +
                "                (\n" +
                "                    SELECT\n" +
                "                        participantid as id,\n" +
                "                        date,\n" +
                "                        enddate\n" +
                "                    FROM " + payor_assignments + "\n" +
                "                    UNION ALL\n" +
                "                    SELECT\n" +
                "                        participantid as id,\n" +
                "                        date,\n" +
                "                        enddate\n" +
                "                    FROM " + assignment + "\n" +
                "                    UNION ALL\n" +
                "                    SELECT\n" +
                "                        participantid as id,\n" +
                "                        date,\n" +
                "                        enddate\n" +
                "                    FROM " + colony_assignments + "\n" +
                "                    UNION ALL\n" +
                "                    SELECT\n" +
                "                        participantid as id,\n" +
                "                        date,\n" +
                "                        enddate\n" +
                "                    FROM " + breedinggroupassignments + "\n" +
                "                    UNION ALL\n" +
                "                    SELECT\n" +
                "                    participantid as id,\n" +
                "                    enddate AS date,\n" +
                "                    enddate\n" +
                "                    FROM " + assignment + " WHERE assignmentStatus = 'S' AND enddate IS NOT NULL\n" +
                "                ) sub\n" +
                "                INNER JOIN " + payor_assignments + " payor \n" +
                "                ON sub.id = payor.participantid AND sub.date >= payor.date AND \n" +
                "                sub.date < coalesce(payor.enddate, getdate())\n" +
                "                INNER JOIN " + assignment + " prim \n" +
                "                ON sub.id = prim.participantid AND sub.date >= prim.date AND \n" +
                "                sub.date < coalesce(prim.enddate, getdate()) AND prim.assignmentStatus = 'P'\n" +
                "                INNER JOIN " + breedinggroupassignments + " brgroup \n" +
                "                ON sub.id = brgroup.participantid AND sub.date >= brgroup.date AND \n" +
                "                sub.date < coalesce(brgroup.enddate, getdate())\n" +
                "                INNER JOIN " + colony_assignments + " colony \n" +
                "                ON sub.id = colony.participantid AND sub.date >= colony.date AND \n" +
                "                sub.date < coalesce(colony.enddate, getdate())\n" +
                "                LEFT OUTER JOIN (select * from " + assignment + " where assignmentStatus='S') sec \n" +
                "                ON sub.id = sec.participantid AND sub.date >= sec.date AND sub.date < coalesce(sec.enddate, getdate())\n" +
                "\t) sub2\n" +
                "\tgroup by\n" +
                "\tid,\n" +
                "\tdate,\n" +
                "\trelease_date,\n" +
                "\tpayorId,\n" +
                "\tprimaryProject,\n" +
                "\tsecondaryProjects,\n" +
                "\tcolonyCode,\n" +
                "\tgroupCode\n");

        return sql;
    }

    private void setupColumns()
    {
        ExprColumn assigned = new ExprColumn(this, "assigned", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".assigned"), JdbcType.DATE);
        assigned.setSortDirection(Sort.SortDirection.DESC);
        addColumn(assigned);

        ExprColumn releaseDate = new ExprColumn(this, "releaseDate", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".releaseDate"), JdbcType.DATE);
        releaseDate.setHidden(true);
        addColumn(releaseDate);

        addColumn(new ExprColumn(this, "id", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".id"), JdbcType.VARCHAR));
        addColumn(new ExprColumn(this, "released", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".released"), JdbcType.DATE));
        addColumn(new ExprColumn(this, "payorId", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".payorId"), JdbcType.VARCHAR));
        addColumn(new ExprColumn(this, "primaryProject", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".primaryProject"), JdbcType.VARCHAR));
        addColumn(new ExprColumn(this, "secondaryProjects", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".secondaryProjects"), JdbcType.VARCHAR));
        addColumn(new ExprColumn(this, "colonyCode", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".colonyCode"), JdbcType.VARCHAR));
        addColumn(new ExprColumn(this, "groupCode", new SQLFragment(ExprColumn.STR_TABLE_ALIAS + ".groupCode"), JdbcType.VARCHAR));
    }

    @Override
    public boolean isPublic()
    {
        return true;
    }

    public String getDatasetTableName(String datasetName)
    {
        Study study = StudyService.get().getStudy(getUserSchema().getContainer());
        Dataset dataset = study.getDatasetByName(datasetName);
        TableInfo tableInfo = dataset.getTableInfo(getUserSchema().getUser());
        return tableInfo.getDomain().getStorageTableName();
    }
}