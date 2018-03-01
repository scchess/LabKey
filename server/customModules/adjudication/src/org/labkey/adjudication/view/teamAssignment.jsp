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
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page import="org.labkey.adjudication.AdjudicationController.ManageSettingsForm" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("Ext4");
        dependencies.add("adjudication/ManageAdjudicatorTeams.js");
    }
%>
<%
    HttpView<ManageSettingsForm> me = (HttpView<ManageSettingsForm>) HttpView.currentView();
    ManageSettingsForm bean = me.getModelBean();

%>
<div id="adjTeamAssignmentForm"></div>

<script type="text/javascript">
    Ext4.onReady(function()
    {
        Ext4.create('LABKEY.adj.ManageAdjudicatorTeams', {
            renderTo: 'adjTeamAssignmentForm',
            teamCount: <%=bean.getAdjudicatorTeamCount()%>
        });
    });
</script>