<%
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
%>
<%@ page import="org.labkey.adjudication.AdjudicationController.AdjudicationIdForm" %>
<%@ page import="org.labkey.adjudication.AdjudicationManager" %>
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
        dependencies.add("adjudication/ActiveDeterminations.js");
        dependencies.add("adjudication/HtmlForSpecificDataTypes.js");
        dependencies.add("adjudication/MakeDetermination.js");
    }
%>
<%
    HttpView<AdjudicationIdForm> me = (HttpView<AdjudicationIdForm>) HttpView.currentView();
    AdjudicationIdForm bean = me.getModelBean();

    boolean requiresHiv1 = AdjudicationManager.get().requiresHiv1Determination(getContainer());
    boolean requiresHiv2 = AdjudicationManager.get().requiresHiv2Determination(getContainer());
%>

<div id='active-cases-combo' class='determ-case-combo'></div>
<div id='active-determination' class='determ-case-details'></div>

<script type="text/javascript" >
    Ext4.onReady(function()
    {
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'getPermissions'),
            method: 'GET',
            success: function (response) {
                var responseText = Ext4.JSON.decode(response.responseText);
                if (!responseText.hasAdjudication)
                {
                    document.getElementById('active-cases-combo').style.display = 'none';
                    document.getElementById('active-determination').innerHTML = '<div class="labkey-error">'
                            + 'You do not have permission to view this adjudication determination.</div>';
                }
                else
                {
                    Ext4.create('LABKEY.adj.ActiveDeterminationsCombo', {
                        renderTo: 'active-cases-combo',
                        determRenderId: 'active-determination',
                        adjid: <%=bean.getAdjid()%>,
                        requiresHiv1: <%=requiresHiv1%>,
                        requiresHiv2: <%=requiresHiv2%>
                    });
                }
            },
            failure: LABKEY.Utils.getCallbackWrapper(function (json, response, options) {
                Ext4.Msg.alert("Failure", "Determination failed: " + response.responseText);
            })
        });
    });
</script>