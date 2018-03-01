<%
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
%>
<%@ page import="org.labkey.adjudication.AdjudicationController.AdjudicationIdForm" %>
<%@ page import="org.labkey.adjudication.AdjudicationManager" %>
<%@ page import="org.labkey.adjudication.security.AdjudicationCaseUploadPermission" %>
<%@ page import="org.labkey.api.security.permissions.AdminPermission" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("clientapi/ext4");
        dependencies.add("adjudication/Adjudication.css");
        dependencies.add("adjudication/Adjudication.js");
        dependencies.add("adjudication/AdjudicationReview.js");
        dependencies.add("adjudication/HtmlForSpecificDataTypes.js");
    }
%>
<%
    HttpView<AdjudicationIdForm> me = (HttpView<AdjudicationIdForm>) HttpView.currentView();
    AdjudicationIdForm bean = me.getModelBean();

    boolean hasCaseUpload = getViewContext().hasPermission(AdjudicationCaseUploadPermission.class);
    boolean hasAdmin = getViewContext().hasPermission(AdminPermission.class);

    boolean requiresHiv1 = AdjudicationManager.get().requiresHiv1Determination(getContainer());
    boolean requiresHiv2 = AdjudicationManager.get().requiresHiv2Determination(getContainer());
%>

<div id='adjError' class='labkey-error' style='display:none;'></div>
<div id='adjReviewDetails'></div>

<div class="result-field-header">Uploaded Text Files for this Case</div>
<div id="caseDocuments"></div>

<script type="text/javascript">
    Ext4.onReady(function ()
    {
        var caseId = <%=bean.getAdjid()%>,
            isAdminReview = <%=bean.isAdminReview()%>,
            canEditComments = <%=hasAdmin || hasCaseUpload%>,
            canVerifyReceipt = <%=hasCaseUpload%>,
            adjUtil = Ext4.create('LABKEY.adj.AdjudicationUtil');

        if (caseId && caseId != null)
        {
            var titlePrefix = "Adjudication Review";
            if (LABKEY.getModuleContext("adjudication").ProtocolName != null)
                titlePrefix = LABKEY.getModuleContext("adjudication").ProtocolName + " - " + titlePrefix;
            LABKEY.NavTrail.setTrail(Ext4.util.Format.htmlEncode(titlePrefix + " - Case ID " + caseId));

            Ext4.Ajax.request({
                url: LABKEY.ActionURL.buildURL('adjudication', 'getPermissions'),
                method: 'GET',
                jsonData: {},
                success: function (response) {
                    var responseText = Ext4.JSON.decode(response.responseText);
                    if ((isAdminReview && (!responseText.hasReview && !responseText.hasAdmin)) || (!isAdminReview && !responseText.hasAdjudication))
                    {
                        document.getElementById('adjError').innerText = 'You do not have permission to view this adjudication review.';
                        document.getElementById('adjError').style.display = 'inline';
                    }
                    else
                    {
                        LABKEY.Query.selectRows({
                            schemaName: 'adjudication',
                            queryName: 'Adjudication Dashboard',
                            filterArray: [LABKEY.Filter.create('CaseId', caseId)],
                            failure: adjUtil.failureHandler,
                            success: function(data)
                            {
                                if (data.rows.length != 1)
                                {
                                    document.getElementById('adjError').innerText = 'Adjudication ID ' + caseId + ' not found.';
                                    document.getElementById('adjError').style.display = 'inline';
                                }
                                else
                                {
                                    Ext4.create('LABKEY.adj.AdjudicationReview', {
                                        renderTo: 'adjReviewDetails',
                                        adjid: <%=bean.getAdjid()%>,
                                        ptid: data.rows[0].ParticipantId,
                                        requiresHiv1: <%=requiresHiv1%>,
                                        requiresHiv2: <%=requiresHiv2%>,
                                        isAdminReview: isAdminReview,
                                        canEditComments: canEditComments,
                                        canVerifyReceipt: canVerifyReceipt,
                                        currentCaseData: {
                                            caseSummary: data.rows[0]
                                        }
                                    });

                                    if (LABKEY.user && LABKEY.user.isAdmin) {

                                        new LABKEY.QueryWebPart({
                                            renderTo: 'caseDocuments',
                                            schemaName: 'adjudication',
                                            queryName: 'CaseDocuments',
                                            columns: 'CaseId,DocumentName,Created,CreatedBy,Modified,ModifiedBy',
                                            dataRegionName : 'documents',
                                            showImportDataButton : false,
                                            showInsertNewButton : false,
                                            showDeleteButton : false,
                                            showExportButtons : false,
                                            frame: 'none',
                                            filters: [
                                                LABKEY.Filter.create('caseId', caseId, LABKEY.Filter.Types.EQUALS)
                                            ]
                                        });
                                    }
                                }
                            }
                        });
                    }
                },
                failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options) {
                    Ext4.Msg.alert("Failure", "Determination failed: " + response.responseText);
                })
            });
        }
        else
        {
            document.getElementById('adjError').innerText = 'No adjudication ID provided.';
            document.getElementById('adjError').style.display = 'inline';
        }
    });
</script>