<%
/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
<%@ page import="org.labkey.adjudication.AdjudicationManager" %>
<%@ page import="org.labkey.adjudication.security.AdjudicationReviewPermission" %>
<%@ page import="org.labkey.api.security.permissions.AdminPermission" %>
<%@ page import="org.labkey.api.util.UniqueID" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("Ext4");
        dependencies.add("adjudication/Dashboard.js");
    }
%>
<%
    boolean hasReviewPermission = getViewContext().hasPermission(AdjudicationReviewPermission.class);
    boolean hasAdmin = getViewContext().hasPermission(AdminPermission.class);
    int numAdjudicatorTeams = AdjudicationManager.get().getNumberOfAdjudicatorTeams(getContainer());
    String renderId = "admin-dashboard-" + UniqueID.getRequestScopedUID(HttpView.currentRequest());
%>

<p>This dashboard can be used to see the current state of each adjudication case, as well as to view various different
    pieces of information about each case. For each adjudication case there is also a link to view further details
    about that case.</p>
<div id="<%=h(renderId)%>"></div>

<script type="text/javascript" >
    Ext4.onReady(function()
    {
        Ext4.create('LABKEY.adj.Dashboard', {
            renderTo: <%=q(renderId)%>,
            isAdjudicationAdmin: true,
            hasPermission: <%=hasReviewPermission || hasAdmin%>,
            numAdjudicatorTeams: <%=numAdjudicatorTeams%>
        });
    });
</script>