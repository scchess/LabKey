/*
 * Copyright (c) 2009 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
if (!LABKEY.Assay.Elisa)
    LABKEY.Assay.Elisa = {};

LABKEY.Assay.Elisa.RunView = function(config)
{
    if (!config.run)
        throw "RunView: Run required in config";
    if (!config.run.id)
        throw "RunView: Run does not have an id";

    var run = config.run;
    var plate = config.plate;
    var editable = config.editable;

    function percent(n) {
        return Math.round(n * 100) + "%";
    }

    function run_eltId() {
      return "run_" + run.id + "_div";
    }

    function runName_eltId() {
      return "run_" + run.id + "_name_span";
    }

    function plate_eltId() {
        return run_eltId() + "_plate";
    }

    function summary_eltId() {
        return run_eltId() + "_summary";
    }

    function dilutionHeader_baseId(dilutionIndex) {
      return "run_" + run.id + "_dilution" + dilutionIndex;
    }

    function dilutionHeader_fieldId(dilutionIndex) {
      return dilutionHeader_baseId(dilutionIndex) + "_field";
    }

    function participantHeader_baseId(dataIndex) {
      return "run_" + run.id + "_participant" + dataIndex;
    }

    function participantHeader_fieldId(dataIndex) {
      return participantHeader_baseId(dataIndex) + "_field";
    }

    function cutoffDilution_eltId(dataIndex) {
      return "run_" + run.id + "_cutoff" + dataIndex + '_span';
    }

    function status_eltId(dataIndex) {
      return "run_" + run.id + "_status" + dataIndex + '_img';
    }

    function titer_text(resultRow) {
        if (null == resultRow || null == resultRow.Titer)
            return "&nbsp;"

      return h(resultRow.TiterOORIndicator) + resultRow.Titer;
    }

    function getStatusInfo(status)
    {
        if (status == null)
            return {
                value:null,
                img:LABKEY.ActionURL.getContextPath() + "/elisa/images/nostatus.png",
                title:"No status. Click to approve or reject",
                next:"Approved"
        };
        else if (status == "Approved")
            return {
                value:"Approved",
                img:LABKEY.ActionURL.getContextPath() + "/elisa/images/check.png",
                title:"Approved. Click to change status",
                next:"Rejected"
        };
        else if (status == "Rejected")
            return {
                value:"Rejected",
                img:LABKEY.ActionURL.getContextPath() + "/elisa/images/cancel.png",
                title:"Rejected. Click to change status",
                next:null
        };
        else return {
                value:null,
                img:LABKEY.ActionURL.getContextPath() + "/elisa/images/nostatus.png",
                title:status + "Click to approve or reject",
                next:"Approved"
        };
    }

    function status_img(dataIndex)
    {
        var status = getStatus(dataIndex);
        var statusInfo = getStatusInfo(status);
        return "<img id='" + status_eltId(dataIndex) + "' title='" + statusInfo.title + "' src='" + statusInfo.img + "'>";
    }

    function getStatus(dataIndex) {
        var resultRow = getResultRow(dataIndex);
        if (null != resultRow)
            return resultRow.Status;
        else
            return null;
    }

    function getResultRow(dataIndex) {
        for (var i = 0; i < run.dataRows.length; i++)
            if (run.dataRows[i].SampleIndex == dataIndex)
                return run.dataRows[i];

        return null;
    }

    function well_eltId(row, col) {
      return "run_" + run.id + "_well_" + row + "_" + col;
    }

    function highlightProblems(cutoff) {
        for (var r = 0; r < plate.wells.length; r++)
        {
            for (var c = 0; c < plate.wells[r].length; c++)
            {
                var wellElt = Ext.fly(well_eltId(r, c));
                if (wellElt)
                {
                    if (plate.wells[r][c].percentDiff > cutoff)
                        wellElt.addClass("badWell");
                    else
                        wellElt.removeClass("badWell");
                }
            }
         }
    }

    function updateStatus() {
        for (var resultIndex = 0; resultIndex < run.dataRows.length; resultIndex++)
        {
            var result = run.dataRows[resultIndex];
            var statusInfo = getStatusInfo(result.Status);
            var elt = Ext.getDom(status_eltId(result.SampleIndex));
            if (null == elt)
                continue;
            elt.src = statusInfo.img;
            elt.title = statusInfo.title;
        }
    }

    var summaryMode = false;

    var view = {
        dilutionInputs: [],
        participantIdInputs:[],
        getRun: function() {
            return run;
        },
        setRun: function(newRun) {
            run = newRun;
        },
        getPlate: function() {
            return plate;
        },
        setPlate: function(newPlate) {
            plate = newPlate;
        },
        setEditable: function (newEditable) {
            editable = newEditable;
        },
        isEditable: function() {
            return editable;
        },

        destroy: function() {
            var runDiv = Ext.get(run_eltId());
            if (runDiv)
            {
                runDiv.remove();
                this.destroyComponents();
                delete LABKEY.Assay.Elisa.runMap[run.id];                
            }

        },

        setSummaryMode: function (newMode) {
            summaryMode = newMode;
        },

        destroyComponents: function()
        {
            for (var i = 0; i < 11; i++)
            {
                var cmp = Ext.getCmp(dilutionHeader_fieldId(i));
                if (cmp)
                    cmp.destroy();
            }

            for (var i = 0; i < 4; i++)
            {
                var cmp = Ext.getCmp(participantHeader_fieldId(i));
                if (cmp)
                    cmp.destroy();
            }

        },

        update: function()
        {
            Ext.get(runName_eltId()).update(this.getPlateHeaderHtml());
            if (!plate)
                return;

            var plateEl = Ext.get(plate_eltId());
            var summaryEl = Ext.get(summary_eltId());
            if (summaryMode)
            {
                if (plateEl)
                {
                    plateEl.remove();
                    this.destroyComponents();
                }
                if (!summaryEl)
                    this.renderSummary();
                else
                {
                    updateStatus();
                    highlightProblems(IaviElisa.percentDiffCutoff);
                }
            }
            else
            {
                if (summaryEl)
                    summaryEl.remove();

                if (plateEl)
                {
                    if (editable)
                    {
                        for (var i = 0; i < 11; i++)
                            Ext.getCmp(dilutionHeader_fieldId(i)).setValue(getRunDilution(run, i));

                        for (var i = 0; i < 4; i++)
                            Ext.getCmp(participantHeader_fieldId(i)).setValue(getParticipant(run, i));
                    }

                    for (var r = 0; r < plate.wells.length / 2; r ++)
                    {
                            var resultRow = getResultRow(r);
                            Ext.get(cutoffDilution_eltId(r)).update(titer_text(resultRow));
                    }

                    highlightProblems(IaviElisa.percentDiffCutoff);
                }
                else
                    this.renderPlate();
            }
        },

        createDilutionCombo: function(col)
        {
            var id = dilutionHeader_baseId(col);
            var value = getRunDilution(run, col);
            var dilutions = [
                "1:100", "1:200", "1:400",
                "1:800", "1:1600", "1:3200",
                "1:6400", "1:12800", "1:25600",
                "1:51200", "1:102400", "1:204800",
                "1:409600", "1:1638400", "1:6553600",
            "1:26214400", "Neg Sera (1:100)", "No Sera"];

            var combo =  new Ext.form.ComboBox({
                  renderTo: id,
                  id: dilutionHeader_fieldId(col),
                  width: 70,
                  allowBlank: false,
                  selectOnFocus: true,
                  store: dilutions,
                  value: value,
                  triggerAction:'all',
                  listeners: {
                      "change":      function (field, newValue, oldValue) {
                        setRunDilution(run, col, newValue);
                        setDirty(true);
                    }
                  }
              });

            return combo;
        },

        createParticipantTextBox: function(dataIndex)
        {
            var id = participantHeader_baseId(dataIndex);
            var value = getParticipant(run, dataIndex);
            //noinspection JSUnusedLocalSymbols
            var textField = new Ext.form.TextField({
                  renderTo: id,
                  id: participantHeader_fieldId(dataIndex),
                  width: 70,
                  value: value,
                  listeners: {
                      "change":         function (field, newValue, oldValue) {
                  setParticipant(run, dataIndex, newValue);
                  setDirty(true);
                }
                  }
              });

            return textField;
        },
        
        render: function(parentDiv) {
            if (null != Ext.get(run_eltId()))
                this.update();
            else
            {
                Ext.fly(parentDiv).insertHtml('beforeEnd', this.getDiv());
                if (summaryMode)
                    this.renderSummary();
                else
                    this.renderPlate();
            }
        },

        renderPlate: function()
        {
            if (null != Ext.get(plate_eltId()))
            {
                this.update();
                return;
            }

            if (null == plate)
                return;

            Ext.fly(run_eltId()).insertHtml('beforeEnd', this.getTable());
            if (editable)
            {
                for (var i = 0; i < 4; i++)
                    this.participantIdInputs[i] = this.createParticipantTextBox(i);

                for (i = 0; i < 11; i++)
                    this.dilutionInputs[i] = this.createDilutionCombo(i);
            }
            for (var r = 0; r < plate.wells.length; r++)
                for (var c = 0; c < plate.wells[r].length; c++)
                    if (plate.wells[r][c].adjustedMean)
                        Ext.QuickTips.register({target:well_eltId(r, c), text:"Adjusted Mean: " + _fmt(plate.wells[r][c].adjustedMean) + ", % Difference: " + percent(plate.wells[r][c].percentDiff)});

            highlightProblems(IaviElisa.percentDiffCutoff);
        },

        renderSummary: function()
        {
            var plateElt = Ext.fly(plate_eltId());
            if (plateElt)
            {
                plateElt.remove();
                this.destroyComponents();
            }

            if (Ext.fly(summary_eltId()))
                return;
            
            Ext.fly(run_eltId()).insertHtml('beforeEnd', this.getSummaryTable());
            for (var r = 0; r < plate.wells.length; r += 2)
            {
                var resultRow = getResultRow(r/2);
                if (null == resultRow)
                    continue;

                for (var c = 0; c < plate.wells[r].length; c++)
                    if (plate.wells[r][c].adjustedMean)
                        Ext.QuickTips.register({target:well_eltId(r, c), text:"Raw Values: " + plate.wells[r][c].valueText + ", " + plate.wells[r+1][c].valueText + ", Percent Difference: " + percent(plate.wells[r][c].percentDiff)});


                this.handleStatus(r/2);
            }
            highlightProblems(IaviElisa.percentDiffCutoff);
        },

        handleStatus: function(dataIndex)
        {
            //noinspection JSUnusedLocalSymbols
            Ext.get(status_eltId(dataIndex)).on("click", function (evt, elt) {
                var statusInfo = getStatusInfo(getStatus(dataIndex));
                var nextStatusInfo = getStatusInfo(statusInfo.next);
                elt.src = nextStatusInfo.img;
                elt.title = nextStatusInfo.title;
                var statusRow = getResultRow(dataIndex);
                statusRow.Status = nextStatusInfo.value;
                setDirty(true);
            });
        },


        getDiv: function()
        {
            return "<div id='" + run_eltId() + "'><br><span id='" + runName_eltId() + "'>" + this.getPlateHeaderHtml() + "</span></div>";
        },

        getPlateHeaderHtml: function()
        {
            if (null == run)
                return "";

            var html = "";
            if (null != run.dataInputs && run.dataInputs.length > 0)
            {
                var href = LABKEY.ActionURL.buildURL("experiment", "showFile", null, {rowId:run.dataInputs[0].id});
                html += "<a href='" + href + "'>" + h(run.dataInputs[0].name) + "</a>: ";
            }
            html += h(run.name);

            return html;
        },

        getSummaryTable: function()
        {
            var html = "<table id='" + summary_eltId() + "' class='labkey-data-region labkey-show-borders'><tr class='labkey-row'>";
            html += "<th class='labkey-col-header-filter'>Subject</th><th class='labkey-col-header-filter'>Titer</th><th>Status</th>";
            for (var c = 0; c < plate.dilutions.length; c++)
                html += "<th class='labkey-col-header-filter' style='padding-right:15px;padding-top:2px;' id='" + dilutionHeader_baseId(c) +"'>" + plate.dilutions[c] + "</th>";
            html += "</tr>";

            for (var r = 0; r < plate.wells.length; r++)
            {
                if (r % 2 == 0)
                {
                    var resultRow = getResultRow(r/2);
                    if (null == resultRow)
                        continue;
                    html += "<tr>";
                    html += "<td id='" + participantHeader_baseId(r/2) + "' >" + _nbsp(resultRow.ParticipantID) + "</td>";
                    html += "<td id='" + cutoffDilution_eltId(r/2) + "' >" + titer_text(resultRow) + "</td>";
                    html += "<td>" + status_img(r/2) + "</td>";
                    for (var c = 0; c < plate.wells[r].length; c++)
                        html += "<td id='" +  well_eltId(r, c) +"' " + (plate.wells[r][c].highlight ? "class='labkey-form-label' " : " ") +
                                ">" + _fmt(plate.wells[r][c].adjustedMean) + "</td>";
                    html += "</tr>";
                }
            }
            html += "</table>";
            return html;
        },

        getTable: function()
        {
            var html = "<table id='" + plate_eltId() + "' class='labkey-data-region labkey-show-borders'><tr class='labkey-row'>";
            html += "<th class='labkey-col-header-filter'>Subject</th><th class='labkey-col-header-filter'>Titer</th>";
            for (var c = 0; c < plate.dilutions.length; c++)
                html += "<th class='labkey-col-header-filter' style='padding-right:15px;padding-top:2px;' id='" + dilutionHeader_baseId(c) +"'>" + (editable ? "" : plate.dilutions[c]) + "</th>";
            html += "</tr>";

            for (var r = 0; r < plate.wells.length; r++)
            {
                html += "<tr>";
                if (r % 2 == 0)
                {
                    var resultRow = getResultRow(r/2);
                    html += "<td id='" + participantHeader_baseId(r/2) + "' rowspan=2>" + (editable ? "" : _nbsp(resultRow ? resultRow.ParticipantID : null)) + "</td>";
                    html += "<td id='" + cutoffDilution_eltId(r/2) + "' rowspan=2>" + titer_text(resultRow) + "</td>";
                }
                for (var c = 0; c < plate.wells[r].length; c++)
                    html += "<td id='" +  well_eltId(r, c) +"' " + (plate.wells[r][c].highlight ? "class='labkey-form-label' " : " ") +
                            ">" + plate.wells[r][c].valueText + "</td>";

                html += "</tr>";
            }
            html += "</table>";
            return html;
        }
    };

    return view;
}

function _nbsp(str)
{
    if (null == str || "" == str)
        return "&nbsp;";
    else
        return h(str);
}

function _fmt(n)
{
    return null == n ? "&nbsp;" : ("" + n).substr(0, 5);
}

LABKEY.Assay.Elisa.RunView.runMap = {};
LABKEY.Assay.Elisa.RunView.getView = function(run, plate, editable)
{
    var runView = LABKEY.Assay.Elisa.RunView.runMap[run.id];
    if (runView) //We have a view, but the run instance may be new after save
    {
        runView.setRun(run);
        if (plate)
            runView.setPlate(plate);
        if (arguments.length > 2)
            runView.setEditable(editable);
    }
    else
    {
        runView = new LABKEY.Assay.Elisa.RunView({run:run, plate:plate, editable:editable});
        LABKEY.Assay.Elisa.RunView.runMap[run.id] = runView;
    }

    return runView;
};

