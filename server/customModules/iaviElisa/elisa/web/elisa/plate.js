/*
 * Copyright (c) 2009 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
if (!LABKEY.Assay.Elisa)
    LABKEY.Assay.Elisa = {};

LABKEY.Assay.Elisa.Plate = function (plateTemplate)
{
    if (plateTemplate)
        Ext.apply(this, deepCopy(plateTemplate));
    this.applyDefaults();
    if (!this.wells)
    {
        this.wells = new Array(8);
        for (var r = 0; r < 8; r++)
            this.wells[r] = [{},{},{},{},{},{},{},{},{},{},{},{}];
    }

    //from: http://www.jasonclawson.com/2008/05/29/extjs-javascript-deep-copy/
    function deepCopy(obj) {
       var seenObjects = [];
       var mappingArray = [];
       var	f = function(simpleObject) {
          var indexOf = seenObjects.indexOf(simpleObject);
          if (indexOf == -1) {
             switch (Ext.type(simpleObject)) {
                case 'object':
                   seenObjects.push(simpleObject);
                   var newObject = {};
                   mappingArray.push(newObject);
                   for (var p in simpleObject)
                      newObject[p] = f(simpleObject[p]);
                   newObject.constructor = simpleObject.constructor;
                return newObject;

                case 'array':
                   seenObjects.push(simpleObject);
                   var newArray = [];
                   mappingArray.push(newArray);
                   for(var i=0,len=simpleObject.length; i<len; i++)
                      newArray.push(f(simpleObject[i]));
                return newArray;

                default:
                return simpleObject;
             }
          } else {
             return mappingArray[indexOf];
          }
       };
       return f(obj);
    }
};

LABKEY.Assay.Elisa.Plate.prototype =
{
    /**
     * Extract well values from a data array. Each well gets a valueText property
     * and a value property based on the contents of the array, which is assumed to be a 2D array
     * of strings that may include extraneous rows & columns
     * @param dataArray array of strings
     * @param startRow 0-based row to start grabbing values from defaults to 0
     * @param startCol 0-based col to start grabbing values from
     * @param nRows defaults to 8  (96 well plate)
     * @param nCols defaults to 12 (96 well plate)
     */
    extractWellValues:function(dataArray, startRow, startCol, nRows, nCols)
    {
        if (arguments.length < 2)
            startRow = 0;
        if (arguments.length < 3)
            startCol = 0;
        if (arguments.length < 4)
            nRows = 8;
        if (arguments.length < 5)
            nCols = 12;

        for (var r = 0; r < nRows; r++)
        {
            if (this.wells.length < r)
                this.wells[r] = new Array(nCols);
            var rowData = this.wells[r];
            if (rowData.length < nCols)
                rowData.length = nCols;

            for (var c = 0; c < nCols; c++)
            {
                if(!rowData[c])
                    rowData[c] = {};

                rowData[c].valueText = "" + dataArray[startRow + r][startCol + c];
                try
                {
                    rowData[c].value = + dataArray[startRow + r][startCol + c];
                }
                catch (x) {}
            }
        }
    },

    getColumnWells:function(col)
    {
        var ret = [];
        for (var r = 0; r < this.wells.length; r++)
            ret.push(this.wells[r][col]);

        return new LABKEY.Assay.Elisa.WellSet(ret);
    },


    /**
     * Return a LABKEY.Assay.Elisa.WellSet containing all wells in the row
     * @param row
     * @return {LABKEY.Assay.Elisa.WellSet} Wellset of all wells in the row
     */
    getRowWells:function(row)
    {
        return new LABKEY.Assay.Elisa.WellSet(this.wells[row]);
    },

    /**
     * Return all the wells where every property value for the passed in object equals the value for that property in the well
     * @param {Object} props
     * @return {LABKEY.Assay.Elisa.WellSet} with all matching wells
     */
    collectMatches:function(props)
    {
        var ret = [];
        this.eachWell(function(well) {
            for (var prop in props)
                if (well[prop] != props[prop])
                    return;

            ret.push(well)
        });

        return new LABKEY.Assay.Elisa.WellSet(ret);
    },

    /**
     *
     * @param fn {Function} to call on every well
     * @param scope {Object} scope for calling fn
     */
    eachWell: function(fn, scope)
    {
        for (var r = 0; r < this.wells.length; r++)
        {
            var row = this.wells[r];
            for (var c = 0; c < row.length; c++)
                fn.call(scope, row[c]);
        }
    },

    applyDefaults: function()
    {
        if (!this.defaultRow)
            return;

        for (var r = 0; r < this.wells.length; r++)
        {
            for (var c = 0; c < this.defaultRow.length; c++)
            {
                if (!this.wells[r][c])
                    this.wells[r][c] = {};

                if (this.defaultRow)
                    Ext.applyIf(this.wells[r][c], this.defaultRow[c]);
                if (this.defaultColumn)
                    Ext.applyIf(this.wells[r][c], this.defaultColumn[r]);
            }
        }
    },

    toHTML: function()
    {
        var html = "<table>";
        for (var r = 0; r < this.wells.length; r++)
        {
            html += "<tr>";
            var row = this.wells[r];
            for (var c = 0; c < row.length; c++)
                html += "<td>" + row[c].value + "</td>";
            html += "</tr>";
        }
        html += "</table>";

        return html;
    }

};

LABKEY.Assay.Elisa.WellSet = function(wellArray)
{
    return {
        wells:wellArray,
        eachWell:function(fn, scope)
        {
            for (var c = 0; c < this.wells.length; c++)
                fn.call(scope, this.wells[c]);
        },

        mean:function()
        {
            var total = 0;
            var count = 0;
            for (var c = 0; c < this.wells.length; c++)
                if (typeof this.wells[c].value == "number")
                {
                    total += this.wells[c].value;
                    count++;
                }

            if (count == 0)
                return null;

            return total/count;
        },

        percentDiff:function()
        {
            if (this.wells.length != 2)
                throw "Percent Diff doesn't make sense for more than two cells";

            return Math.abs((this.wells[0].value - this.wells[1].value)/((this.wells[0].value + this.wells[1].value) / 2));
        },

        setProp:function(propName, value)
        {
            for (var c = 0; c < this.wells.length; c++)
                this.wells[c][propName] = value;
        }
    }
}

//Plate layout for standard assay.
//NOTE: By default using sample for same animal for background computation
LABKEY.Assay.Elisa.ExcelPlateLayout = {
    samples:[null, null, null, null],
    dilutions:["1:100","1:400","1:1600","1:3200","1:6400","1:12800","1:25600","1:51200","1:102400","1:204800","1:409600","Neg Sera (1:100)"],
    cutoff:.2,
    wells:[
[{wellType:'Positive Control',dilution:"1:100"},{wellType:'Positive Control',dilution:"1:400"},{wellType:'Positive Control',dilution:"1:1600"},{wellType:'Positive Control',dilution:"1:3200"},{wellType:'Positive Control',dilution:"1:6400"},{wellType:'Positive Control',dilution:"1:12800"},{wellType:'Positive Control',dilution:"1:25600"},{wellType:'Positive Control',dilution:"1:51200"},{wellType:'Positive Control',dilution:"1:102400"},{wellType:'Positive Control',dilution:"1:204800"},{wellType:'Positive Control',dilution:"1:409600"},{wellType:'Blank',dilution:"Neg Sera (1:100)"}],
[{wellType:'Positive Control',dilution:"1:100"},{wellType:'Positive Control',dilution:"1:400"},{wellType:'Positive Control',dilution:"1:1600"},{wellType:'Positive Control',dilution:"1:3200"},{wellType:'Positive Control',dilution:"1:6400"},{wellType:'Positive Control',dilution:"1:12800"},{wellType:'Positive Control',dilution:"1:25600"},{wellType:'Positive Control',dilution:"1:51200"},{wellType:'Positive Control',dilution:"1:102400"},{wellType:'Positive Control',dilution:"1:204800"},{wellType:'Positive Control',dilution:"1:409600"},{wellType:'Blank',dilution:"Neg Sera (1:100)"}],
[{wellType:'Sample',sampleIndex:1,dilution:"1:100"},{wellType:'Sample',sampleIndex:1,dilution:"1:400"},{wellType:'Sample',sampleIndex:1,dilution:"1:1600"},{wellType:'Sample',sampleIndex:1,dilution:"1:3200"},{wellType:'Sample',sampleIndex:1,dilution:"1:6400"},{wellType:'Sample',sampleIndex:1,dilution:"1:12800"},{wellType:'Sample',sampleIndex:1,dilution:"1:25600"},{wellType:'Sample',sampleIndex:1,dilution:"1:51200"},{wellType:'Sample',sampleIndex:1,dilution:"1:102400"},{wellType:'Sample',sampleIndex:1,dilution:"1:204800"},{wellType:'Sample',sampleIndex:1,dilution:"1:409600"},{wellType:'Negative Control',sampleIndex:1,dilution:"Neg Sera (1:100)"}],
[{wellType:'Sample',sampleIndex:1,dilution:"1:100"},{wellType:'Sample',sampleIndex:1,dilution:"1:400"},{wellType:'Sample',sampleIndex:1,dilution:"1:1600"},{wellType:'Sample',sampleIndex:1,dilution:"1:3200"},{wellType:'Sample',sampleIndex:1,dilution:"1:6400"},{wellType:'Sample',sampleIndex:1,dilution:"1:12800"},{wellType:'Sample',sampleIndex:1,dilution:"1:25600"},{wellType:'Sample',sampleIndex:1,dilution:"1:51200"},{wellType:'Sample',sampleIndex:1,dilution:"1:102400"},{wellType:'Sample',sampleIndex:1,dilution:"1:204800"},{wellType:'Sample',sampleIndex:1,dilution:"1:409600"},{wellType:'Negative Control',sampleIndex:1,dilution:"Neg Sera (1:100)"}],
[{wellType:'Sample',sampleIndex:2,dilution:"1:100"},{wellType:'Sample',sampleIndex:2,dilution:"1:400"},{wellType:'Sample',sampleIndex:2,dilution:"1:1600"},{wellType:'Sample',sampleIndex:2,dilution:"1:3200"},{wellType:'Sample',sampleIndex:2,dilution:"1:6400"},{wellType:'Sample',sampleIndex:2,dilution:"1:12800"},{wellType:'Sample',sampleIndex:2,dilution:"1:25600"},{wellType:'Sample',sampleIndex:2,dilution:"1:51200"},{wellType:'Sample',sampleIndex:2,dilution:"1:102400"},{wellType:'Sample',sampleIndex:2,dilution:"1:204800"},{wellType:'Sample',sampleIndex:2,dilution:"1:409600"},{wellType:'Negative Control',sampleIndex:2,dilution:"Neg Sera (1:100)"}],
[{wellType:'Sample',sampleIndex:2,dilution:"1:100"},{wellType:'Sample',sampleIndex:2,dilution:"1:400"},{wellType:'Sample',sampleIndex:2,dilution:"1:1600"},{wellType:'Sample',sampleIndex:2,dilution:"1:3200"},{wellType:'Sample',sampleIndex:2,dilution:"1:6400"},{wellType:'Sample',sampleIndex:2,dilution:"1:12800"},{wellType:'Sample',sampleIndex:2,dilution:"1:25600"},{wellType:'Sample',sampleIndex:2,dilution:"1:51200"},{wellType:'Sample',sampleIndex:2,dilution:"1:102400"},{wellType:'Sample',sampleIndex:2,dilution:"1:204800"},{wellType:'Sample',sampleIndex:2,dilution:"1:409600"},{wellType:'Negative Control',sampleIndex:2,dilution:"Neg Sera (1:100)"}],
[{wellType:'Sample',sampleIndex:3,dilution:"1:100"},{wellType:'Sample',sampleIndex:3,dilution:"1:400"},{wellType:'Sample',sampleIndex:3,dilution:"1:1600"},{wellType:'Sample',sampleIndex:3,dilution:"1:3200"},{wellType:'Sample',sampleIndex:3,dilution:"1:6400"},{wellType:'Sample',sampleIndex:3,dilution:"1:12800"},{wellType:'Sample',sampleIndex:3,dilution:"1:25600"},{wellType:'Sample',sampleIndex:3,dilution:"1:51200"},{wellType:'Sample',sampleIndex:3,dilution:"1:102400"},{wellType:'Sample',sampleIndex:3,dilution:"1:204800"},{wellType:'Sample',sampleIndex:3,dilution:"1:409600"},{wellType:'Negative Control',sampleIndex:3,dilution:"Neg Sera (1:100)"}],
[{wellType:'Sample',sampleIndex:3,dilution:"1:100"},{wellType:'Sample',sampleIndex:3,dilution:"1:400"},{wellType:'Sample',sampleIndex:3,dilution:"1:1600"},{wellType:'Sample',sampleIndex:3,dilution:"1:3200"},{wellType:'Sample',sampleIndex:3,dilution:"1:6400"},{wellType:'Sample',sampleIndex:3,dilution:"1:12800"},{wellType:'Sample',sampleIndex:3,dilution:"1:25600"},{wellType:'Sample',sampleIndex:3,dilution:"1:51200"},{wellType:'Sample',sampleIndex:3,dilution:"1:102400"},{wellType:'Sample',sampleIndex:3,dilution:"1:204800"},{wellType:'Sample',sampleIndex:3,dilution:"1:409600"},{wellType:'Negative Control',sampleIndex:3,dilution:"Neg Sera (1:100)"}]
]
};

//Plate layout for older, SoftMax based assay
//NOTE: This assay does not used matched sera for background...
LABKEY.Assay.Elisa.TextPlateLayout = {
    samples:[null, null, null, null],
    defaultRow:[{wellType:'Sample',dilution:"1:100"},{wellType:'Sample',dilution:"1:200"},{wellType:'Sample',dilution:"1:400"},{wellType:'Sample',dilution:"1:800"},{wellType:'Sample',dilution:"1:1600"},{wellType:'Sample',dilution:"1:3200"},{wellType:'Sample',dilution:"1:6400"},{wellType:'Sample',dilution:"1:12800"},{wellType:'Sample',dilution:"1:25600"},{wellType:'Sample',dilution:"1:51200"},{wellType:'Sample',dilution:"1:102400"},{wellType:'Negative Control',dilution:"1:100"}],
    dilutions:[  "1:100", "1:200", "1:400",  "1:800", "1:1600", "1:3200",  "1:6400", "1:12800", "1:25600",  "1:51200", "1:102400", "Neg Sera (1:100)"],
    cutoff:.2,
    wells:[
[{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{wellType:'Negative Control'}],
[{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{sampleIndex:0},{wellType:'Negative Control'}],
[{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{wellType:'Negative Control'}],
[{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{sampleIndex:1},{wellType:'Negative Control'}],
[{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{wellType:'Negative Control'}],
[{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{sampleIndex:2},{wellType:'Negative Control'}],
[{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{wellType:'Negative Control'}],
[{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{sampleIndex:3},{wellType:'Negative Control'}]
]
};