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
<%@ page import="org.labkey.adjudication.security.AdjudicationPermission" %>
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
    int numAdjudicatorTeams = AdjudicationManager.get().getNumberOfAdjudicatorTeams(getContainer());
    Integer adjudicatorTeamNumber = AdjudicationManager.get().getAdjudicatorTeamNumber(getContainer(), getUser().getUserId());
    boolean hasAdjPermission = adjudicatorTeamNumber != null && getViewContext().hasPermission(AdjudicationPermission.class);
    String renderId = "adj-dashboard-" + UniqueID.getRequestScopedUID(HttpView.currentRequest());
%>

<p>This dashboard can be used to see the current state of each adjudication case, as well as to view various different
    pieces of information about each case. For active adjudication cases, there is a link to update the determination
    for that case. For completed adjudication cases, there is a link to view further details about that case.</p>

<!-- TODO: Use strategy that dataViews.jsp uses for unique ID -->
<div id="<%=h(renderId)%>"></div>

<script type="text/javascript" >
    // initial function to get the whole thing started
    Ext4.onReady(function() {
        Ext4.create('LABKEY.adj.Dashboard', {
            renderTo: <%=q(renderId)%>,
            isAdjudicationAdmin: false,
            hasPermission: <%=hasAdjPermission%>,
            adjudicatorTeamNumber: <%=adjudicatorTeamNumber%>,
            numAdjudicatorTeams: <%=numAdjudicatorTeams%>
        });
    });
</script>
