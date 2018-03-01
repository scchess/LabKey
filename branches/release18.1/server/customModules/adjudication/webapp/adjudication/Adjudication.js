/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('LABKEY.adj.AdjudicationUtil', {

    extend : 'Ext.Component',

    commonFields : [{name: "RowId"}, {name: "CaseId"}, {name: "ParticipantId"}, {name: "EntityId"}, {name: "Visit"},
        {name: "Network"}, {name: "Lab"}, {name: "AssayType"}, {name: "AssayKit"}, {name: "Result"}, {name: "DrawDate"},
        {name: "CopiesML"}, {name: "TestDate"}, {name: "Comment"}, {name: "KitDescription"}, {name: "Attachments"}],


    initComponent: function() {
        this.adjDrawDates = [];
        this.drawDatesStore = null;
        this.assayData = null;
        this.visits = [];
    },

    // function to get a value from the row object, check lowercase if not property not initially found
    getRowValue : function(row, key)
    {
        if (row.hasOwnProperty(key))
            return row[key];
        else
            return row[key.toLowerCase()];
    },

    // function to store the assay data in a structure by visit and assay type
    storeAssayData : function(data)
    {
        // create the new object with the visit being the first "level"
        var tmp = {};
        for (var k = 0; k < this.visits.length; k++)
            tmp[this.visits[k]] = {};

        // loop through each row of the data to store it appropriately
        for (var i = 0; i < data.rows.length; i++)
        {
            var row = data.rows[i];
            var vis = this.getRowValue(row, 'Visit');
            var tmpRow = {};

            // store all EIA's in one "type" (EIA1, EIA2, EIA3)
            var type = this.getRowValue(row, 'AssayType').toLowerCase().replace(/\s/g, '');
            if (Ext4.String.startsWith(type, "eia", true))
                type = "eia";

            if (tmp[vis][type] == undefined)
                tmp[vis][type] = [];

            // add the common result types to the object
            Ext4.each(this.commonFields, function(field)
            {
                tmpRow[field.name] = this.getRowValue(row, field.name);
            }, this);

            // add the data type specific result types to the object
            Ext4.each(this.extendedFields, function(field)
            {
                tmpRow[field.name] = this.getRowValue(row, field.name);
            }, this);

            // add the "band" specific result values to the object
            Ext4.each(this.bandFields, function(field)
            {
                var bandVal = this.getRowValue(row, field.name);
                if (Ext4.isDefined(bandVal) && bandVal != null)
                {
                    if (!Ext4.isDefined(tmpRow.Bands))
                        tmpRow.Bands = {};

                    tmpRow.Bands[field.name] = (bandVal === true ? "Yes" : (bandVal === false ? "No" : bandVal));
                }
            }, this);

            tmp[vis][type].push(tmpRow);
        }

        return tmp;
    },


    // callback function from selectRows api call: get the assay results related to the ptid for the given adj. case
    showAssayResults : function(data, caseSummary) {
        this.dataTypes = Ext4.create('LABKEY.ext4.data.Store', {
            autoLoad: true,
            fields: ['Name', 'Label'],
            schemaName: 'adjudication',
            queryName: 'AssayTypes',
            listeners: {
                scope: this,
                load: function (store) {
                    this._finishShowAssayResults(data, caseSummary)
                }
            }
        });
    },

    _finishShowAssayResults: function(data, caseSummary) {
        this.assayRes = document.getElementById('assayRes');
        if (!this.assayRes)
        {
            return; // unexpected
        }

        // a case should not have been created without assay results being available, but check anyway
        if (data.rows.length == 0)
        {
            this.assayRes.innerHTML = "<br/><span class='result-no-data'>No assay results available for this Participant ID at this time.</span>";
            return;
        }

        // parse the column set for common vs band vs extended assay result fields
        this.parseResultColumns(data);

        // get the list of visits for assay results related to this case (sorted by visit number)
        this.visits = this.getVisitNums(data);

        // store the assay data in a structure by visit and assay type
        this.assayData = this.storeAssayData(data);

        var html = "<br/><table class='result-table' style='min-width: 800px;'>";

        // loop through the visits for this case to generate the display HTML for the assay results
        for (var i = 0; i < this.visits.length; i++)
        {
            var bg = i % 2 == 0 ? '#eeeeee' : '#ffffff';
            var isFirst = true;

            html += "<tr class='result-visit-row'>"
                + "<td class='result-visit-no' bgcolor='" + bg + "'>Visit " + this.visits[i] + "</td>"
                + "<td class='result-visit-data' bgcolor='" + bg + "'><table border='0' cellspacing='0' cellpadding='2'>";

            this.dataTypes.each(function(dataType)
            {
                var assayData = this.assayData[this.visits[i]][dataType.get('Name').toLowerCase()];
                if (Ext4.isDefined(assayData))
                {
                    html += LABKEY.adj.HtmlForSpecificDataTypes.htmlForAssayData(this, assayData, dataType, !isFirst, caseSummary.CompletedDate);
                    isFirst = false;
                }
            }, this);
            html += "</table></td></tr>";
        }
        html += "</table>";

        this.assayRes.innerHTML = html;
    },

    // function to parse the assay result columns into "band" related columns and extended columns
    parseResultColumns : function(data)
    {
        var commonFieldNames = Ext4.Array.pluck(this.commonFields, 'name');
        this.bandFields = [];
        this.extendedFields = [];

        Ext4.each(data.columnModel, function(column)
        {
            var colName = column.dataIndex;
            var index = commonFieldNames.indexOf(colName);
            if (index == -1)
            {
                if (colName.toLowerCase().indexOf("band") == 0 || LABKEY.Utils.endsWith(colName.toLowerCase(), "band"))
                {
                    this.bandFields.push({
                        name: colName,
                        label: column.header
                    });
                }
                else
                {
                    this.extendedFields.push({
                        name: colName,
                        label: column.header
                    });
                }
            }
            else
            {
                this.commonFields[index].label = column.header;
            }
        }, this);
    },

    // function to get the list of visits for assay results related to this case (sorted by visit number)
    getVisitNums : function(data)
    {
        var tmp = [];
        for (var i = 0; i < data.rows.length; i++)
        {
            if (tmp.indexOf(data.rows[i].Visit) == -1)
            {
                tmp[tmp.length] = data.rows[i].Visit;
            }
        }

        // return the visit numbers sorted in ascending order
        return tmp.sort(this.sortVisits);
    },

    // function for sorting visit numbers in ascending order
    sortVisits : function(x, y)
    {
        return (x - y);
    },

    // function for sorting dates in ascending order
    sortByDate : function(a, b)
    {
        var x = new Date(a["date"]);
        var y = new Date(b["date"]);
        return (x - y);
    },

    // function to store the draw dates associated with the given adj. case
    storeDrawDates : function(data)
    {
        var dates = [];
        this.adjDrawDates = [];
        for (var i = 0; i < data.rowCount; i++) {
            if (data.rows[i].DrawDate != null && dates.indexOf(data.rows[i].DrawDate) == -1) {
                this.adjDrawDates.push({"row": data.rows[i].RowId, "date": data.rows[i].DrawDate});
                dates.push(data.rows[i].DrawDate);
            }
        }
        this.adjDrawDates.sort(this.sortByDate);
        for (i = 0; i < this.adjDrawDates.length; i++)
            this.adjDrawDates[i]["date"] = this.formatDate(this.adjDrawDates[i]["date"]);

        this.drawDatesStore = Ext4.create('Ext.data.Store', {
            fields: ['row', 'date'],
            data: this.adjDrawDates
        });
    },

    // generic error callback function for many api calls
    failureHandler : function(errorInfo, response)
    {
        if (errorInfo && errorInfo.exception)
            alert("ERROR: " + errorInfo.exception);
        else
            alert("ERROR: " + response.statusText);
    },

    // function to format date values into dd-mmm-yyyy
    formatDate : function(value)
    {
        if (value == null || value == "" || value == undefined)
            return null;

        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var mmm;
        var dd;

        var d = new Date(value);
        var curr_day = d.getDate();
        dd = "" + curr_day;
        if (dd.length == 1)
            dd = "0" + dd;

        var curr_month = d.getMonth();
        mmm = months[curr_month];

        var yyyy = d.getFullYear();

        return (dd + mmm + yyyy);
    }
});

