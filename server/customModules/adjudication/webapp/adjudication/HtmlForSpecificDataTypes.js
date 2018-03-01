/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('LABKEY.adj.HtmlForSpecificDataTypes', {

    singleton: true,

    space : "&nbsp;&nbsp;&nbsp;&nbsp;",

    htmlForAssayData: function (adjUtil, assaydata, datatype, notFirst, completedDate)
    {
        var tmpHtml = notFirst ? "<tr><td colspan='2'><div class='result-spacer'></div></td></tr>" : "";

        // there may be more than one EIA assay result for a given visit, so display each of them
        for (var i = 0; i < assaydata.length; i++)
        {
            if (i > 0) // add line break
            {
                tmpHtml += "<tr><td>&nbsp;</td></tr>";
            }
            var assayLabel = datatype.get('Label');
            if (!assayLabel || assayLabel.trim().length == 0)
                assayLabel = datatype.get('Name');
            tmpHtml += "<tr><td colspan='2' class='result-assay-type'>" + assayLabel + "</td></tr>";

            tmpHtml += "<tr><td align='left' width='400'><span class='result-field-label'>Results: </span>"
                    + "<span class='result-value'>" + assaydata[i].Result
                    + (Ext4.isDefined(assaydata[i].CopiesML) && assaydata[i].CopiesML != null ? "&nbsp; (" + assaydata[i].CopiesML + " cp/mL)" : "")
                    + "</span></td>";

            tmpHtml += "<td valign='top'><span class='result-field-label'>Collection Date: </span><span class='result-value'>"
                    + adjUtil.formatDate(assaydata[i].DrawDate) + "</span></td></tr>";

            if (Ext4.isDefined(assaydata[i].Bands))
            {
                tmpHtml += "<tr><td colspan='2'><table cellspacing='0' cellpadding='0'><tr>"
                        + "<td class='result-field-label' style='vertical-align: top;'>Bands: </td>"
                        + "<td>&nbsp;</td><td><table cellspacing='0' cellpadding='1' class='result-table'><tr>";

                for (var k = 0; k < adjUtil.bandFields.length; k++)
                {
                    var bandVal = assaydata[i].Bands[adjUtil.bandFields[k].name];
                    if (Ext4.isDefined(bandVal) && bandVal != null)
                    {
                        tmpHtml += "<td class='result-band-cell'>" + adjUtil.bandFields[k].label
                                + "<br/>" + bandVal + "</td>";
                    }
                }

                tmpHtml += "</tr></table></td></tr></table></td></tr>";
            }

            Ext4.each(adjUtil.extendedFields, function(field)
            {
                // Issue 30059: don't show the "Post Complete: true/false" output here
                // as it is used below for a more meaningful message
                if (field.name.toLowerCase() == 'postcomplete')
                    return true; // continue

                if (Ext4.isDefined(assaydata[i][field.name]) && assaydata[i][field.name] != null)
                {
                    tmpHtml += "<tr><td colspan='2' class='result-field-maxwidth'><span class='result-field-label'>"
                            + field.label + ": </span><span class='result-value'>" + assaydata[i][field.name]
                            + "</span></td></tr>";
                }
            }, this);

            if (Ext4.isDefined(assaydata[i]["KitDescription"]) && assaydata[i]["KitDescription"] != null)
            {
                tmpHtml += "<tr><td colspan='2' class='result-field-maxwidth'><span class='result-field-label'>Kit: </span>"
                        + "<span class='result-value'>" + assaydata[i]["KitDescription"] + "</span></td></tr>";
            }

            if (Ext4.isDefined(assaydata[i].Attachments) && assaydata[i].Attachments != null)
            {
                var params = {entityId: assaydata[i].EntityId, name: assaydata[i].Attachments},
                    fileUrl = LABKEY.ActionURL.buildURL('adjudication', 'download', null, params);

                tmpHtml += "<tr><td colspan='2' class='result-field-maxwidth'><span class='result-field-label'>File: </span>"
                        + "<a href='" + fileUrl + "' target='_blank'>" + assaydata[i].Attachments + "</a> "
                        + (LABKEY.user.isAdmin ? "[<a onclick='LABKEY.adj.HtmlForSpecificDataTypes.removeFileAttachment(\"" + params.entityId + "\",\"" + params.name + "\"); return false;'>remove</a>]" : "")
                        + "</td></tr>";
            }

            if (Ext4.isDefined(assaydata[i].Comment) && assaydata[i].Comment != null)
            {
                tmpHtml += "<tr><td colspan='2' class='result-field-maxwidth'><span class='result-field-label'>Comments: </span>"
                        + "<span class='result-value'>" + assaydata[i].Comment + "</span></td></tr>";

            }

            if (assaydata[i].PostComplete){

                tmpHtml += "<tr><td colspan='2' class='result-field-maxwidth'>"
                        + "<span class='labkey-error'>Note: This data was added after the adjudication determination on " + completedDate + " was made.</span></td></tr>";
            }
        }

        return tmpHtml;
    },

    removeFileAttachment : function(entityId, name)
    {
        Ext4.Msg.confirm(
            'Confirm Attachment Deletion',
            'Are you sure you want to remove this attachment? This action can not be undone.',
            function(btnId)
            {
                if (btnId == 'yes')
                {
                    Ext4.Ajax.request({
                        url: LABKEY.ActionURL.buildURL('adjudication', 'deleteAttachAdjudicationFile'),
                        method: 'POST',
                        jsonData: {
                            entityId: entityId,
                            name: name
                        },
                        scope: this,
                        success: function (response)
                        {
                            window.location.reload();
                        },
                        failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options)
                        {
                            Ext4.Msg.alert('Error', json ? json.exception : response.statusText);
                        })
                    });
                }
            },
            this
        );
    }
});

