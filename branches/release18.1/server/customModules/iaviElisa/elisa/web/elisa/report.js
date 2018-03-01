/*
 * Copyright (c) 2009-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
function generateTable(data, columns, sectionColumnName)
{

    var section = null;
    var html = "<table class='labkey-data-region labkey-show-borders'>";
    html += "<tr>";
    for (var iCol =0; iCol < columns.length; iCol++)
    {
        var column = columns[iCol];
        if (column.hidden)
            continue;
        if (column.name != sectionColumnName)
        {
            var caption = (column.caption ? column.caption: column.name);
            if (column.visitDate)
                caption += "<br>" + column.visitDate;
            html += ("<td class='header' style='vertical-align:bottom;border-bottom:1px solid gray'>" + caption + "</td>");
        }
    }
    html += "</tr>";

    var bg = 1;
    for (var iRow = 0; iRow < data.length; iRow++)
    {
        var row = data[iRow];
        if (sectionColumnName && row[sectionColumnName] != section)
        {
            html += "<tr><td colspan=";
            html += columns.length -1;

            html += "><b>";
            section = row[sectionColumnName];
            html += section;

            html += "</b></td></tr>";
            bg = 1;
        }
        if(bg == 1)
        {
            html += "<tr bgcolor='#EEEEEE'>";
            bg = 0;
        }
        else
        {
            html += "<tr>";
            bg = 1;
        }
        for (var i =0; i < columns.length; i++)
        {
            if (columns[i].hidden)
                continue;
            if (columns[i].name == sectionColumnName)
                continue;
            var item;
            if (columns[i].fn)
                item = columns[i].fn(row);
            else
                item = row[columns[i].name];

            if(columns[i].name == 'Screening' && (row[columns[0].name].value == 'Viral Load (1)' || row[columns[0].name].value == 'Viral Load (2)')
                     && item != undefined && scrVlSrc != null)
            {
                item = item + "*";
                annotateScrVlLdSource(scrVlSrc);
            }

            if (null != item && typeof(item) == 'object')
            {
                var itemText;
                if (item.title)
                    itemText = "<span title='" + item.title + "'>" + item.value + "</span>";
                else
                    itemText = "" + item.value;

                if (item.url)
                    item = "<a href='" + item.url + "'>" + itemText + "</a>";
                else
                    item = itemText;

            }
            else if (item == Number.NEGATIVE_INFINITY)
                item = "(Not Detected)";
            if (columns[i].type == "number")
                html += ("<td align=right>" + (item == undefined ? "&nbsp;" : item) + "</td>");
            else
                html += ("<td >" + (item == undefined ? "&nbsp;" : item) + "</td>");
        }
        html += "</tr>";
    }
    html += "</table>";
    return html;
}

function pivot(data, fixedColumns, groupingColumn, dataColumn)
{
    var out = [];
    var rowIndexMap = {};
    var outColumns = [];
    var outColumnMap = {};
    var dataType;

    function displayValue(item)
    {
        if (typeof item == "object")
            return item.displayValue ? item.displayValue : item.value;
        else
            return item;
    }

    function rawValue(item)
    {
        if (typeof item == "object")
            return item.value;
        else
            return item;
    }

    for (var iCol = 0; iCol < fixedColumns.length; iCol++)
    {
        outColumns[iCol] = fixedColumns[iCol];
        outColumns[iCol].sortOrder = iCol - 10000; //These are negative numbers so before all visits
    }

    for (var i = 0; i < data.rowCount; i++)
    {
        var row = data.rows[i];
        var resultRow = {};
        var key = "";
        for (var icol = 0; icol < fixedColumns.length; icol++)
        {
            var colName = fixedColumns[icol].name;
            if (colName == groupingColumn || colName == dataColumn)
                continue;

            key += displayValue(row[colName]);
            key += "|";
            resultRow[colName] =  displayValue(row[colName]);
        }
        var rowIndex = rowIndexMap[key];
        if (rowIndex == null || rowIndex == undefined)
        {
            rowIndexMap[key] = out.length;
            out[out.length] = resultRow;
        }
        else
            resultRow = out[rowIndex];

        var groupingValue = displayValue(row[groupingColumn]);
        var value = displayValue(row[dataColumn]);

        if (!outColumnMap[groupingValue])
        {
            if(groupingColumn == "ParticipantVisit/Visit/Label")
               outColumns[outColumns.length] = {name:groupingValue, sortOrder:rawValue(row["ParticipantVisit/Visit/SequenceNumMin"]), type:(null == value ? "number" : typeof value)};
            else
               outColumns[outColumns.length] = {name:groupingValue, sortOrder:rawValue(row["SequenceNum"]), type:(null == value ? "number" : typeof value)};
            outColumnMap[groupingValue] = true;
        }

        resultRow[groupingValue] = value;
    }

    //Sort output columns by sequenceNum if they have one.
    outColumns.sort(function(a, b) {
        return a.sortOrder - b.sortOrder;
    });
    return {rows:out,columns:outColumns};
}

function showData(datasetName, valueColumn, renderTo)
{
    LABKEY.Query.selectRows({schemaName:"study", queryName:datasetName, requiredVersion:9.1,
        columns:valueColumn +  ",ParticipantId,Day,ParticipantVisit/Visit,ParticipantVisit/Visit/Label,ParticipantVisit/Visit/SequenceNumMin,ParticipantId/Cohort/Label",
        sort:"ParticipantId/Cohort/Label,ParticipantId",
            successCallback:function(data) {
                var pivotData = pivot(data, [{name:"ParticipantId/Cohort/Label", caption:"Cohort"}, {name:"ParticipantId", caption:"Subject"}], "ParticipantVisit/Visit/Label", valueColumn);
                Ext.get(renderTo).update(generateTable(pivotData.rows, pivotData.columns, "ParticipantId/Cohort/Label"));
            }
    });
}
