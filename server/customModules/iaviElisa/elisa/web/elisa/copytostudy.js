/*
 * Copyright (c) 2009 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var copyCount;

function createCopyForm(resultRows)
{
    var queryName = LABKEY.page.assay.name + " Data";
    var dom = {tag:"div"};
    var children = ["<b>Upload is complete. The following rows were approved.<b><br><br>"];
    if (LABKEY.page.batch.properties.TargetStudy)
    {
        children.push("When you click finish, approved rows will be copied to the target study, and the copied data will be shown.<br>");
        children.push({
      tag:"form", id:"copy_form", action:LABKEY.ActionURL.buildURL("assay", "publishConfirm", null, {}), method:"post",
      children:[
          {tag:"input", type:"hidden", name:"rowId", value:LABKEY.page.assay.id},
          {tag:"input", type:"hidden", name:"targetStudy", value:LABKEY.page.batch.properties.TargetStudy},
          {tag:"input", type:"hidden", name:"dataRegionSelectionKey", value:"$assay$" + queryName + "$$" + queryName},
          {tag:"input", type:"hidden", name:"attemptPublish", value:true},
          {tag:"input", type:"hidden", name:"defaultValueSource", value:"UserSpecified"},
          {tag:"div", children:getRows()}]
        });
    }
    else
    {
        children.push("<br>Target Study was not defined so data will not be copied to a study. You can also copy to studies later from the ");
        children.push({tag:"a", href:LABKEY.ActionURL.buildURL("assay", "assayData", null, {rowId:LABKEY.page.assay.id}), html:"Results Page."}),
        children.push({tag:"div", children:getRows()});
    }
    dom.children = children;


    return dom;

    function getRows () {
        copyCount = 0;
        var rows = ["<tr class='labkey-row'><th class='labkey-col-header-filter'>Subject</th><th class='labkey-col-header-filter'>Date</th><th class='labkey-col-header-filter'>Titer</th><th>Status</th>"];
        var copiedCol = "copied_to_" + targetStudyName;
        for (var r = 0; r < resultRows.length; r++)
            {
                var result = resultRows[r];
                if (result["Properties/Status"] == "Approved")
                {
                    var status;
                    var requiresCopy = null != LABKEY.page.batch.properties.TargetStudy && null == result[copiedCol];
                    if (targetStudyName)
                    {
                        if (requiresCopy)
                        {
                            status = "Approved -- will be copied <input type='hidden' name='.select' value='" + result.ObjectId + "'>";
                            copyCount++;
                        }
                        else if (result[copiedCol])
                            status = "Approved -- already copied";
                        else
                            status = "Approved";

                    }
                    rows.push({tag:"tr", cls:"labkey-row", children:
                            [   {tag:"input", type:"hidden", name:"objectId", value:result.ObjectId},
                                {tag:"input", type:"hidden", name:"participantId", value:h(result["Properties/ParticipantID"])},
                                {tag:"input", type:"hidden", name:"date", value:result["Properties/Date"]},
                                {tag:"td",  html:h(result["Properties/ParticipantID"])},
                                {tag:"td", html:result["Properties/Date"]},
                                {tag:"td", style:"width:100", children:h(result["Properties/TiterOORIndicator"]) + " " + result["Properties/Titer"]},
                                {tag:"td", style:"width:100", children:status}
                            ]});
                }
            }

        return {tag:"table", cls:"labkey-data-region labkey-show-borders", children:rows};
    }
}

function renderCopyForm(parentEl, queryResult)
{
    Ext.DomHelper.overwrite(parentEl, createCopyForm(queryResult.rows));
}

function renderCopyToStudy(parentEl)
{
    var columns = "Properties/Status,ObjectId,Properties/Date,Properties/ParticipantID,Properties/Titer,Properties/TiterOORIndicator";
    if (null  != targetStudyName)
        columns += ",copied_to_" + targetStudyName;
    LABKEY.Query.selectRows({schemaName:"Assay", queryName:LABKEY.page.assay.name + " Data",
        columns:columns,
        filterArray:[LABKEY.Filter.create("Run/Batch/RowId", LABKEY.page.batch.id, LABKEY.Filter.Types.EQUAL)],
        sort:"ObjectId",
        successCallback: function (result) {
            renderCopyForm(parentEl, result);
        },
        errorCallback: function (data) {
            console.log(data);
        }
    });
}