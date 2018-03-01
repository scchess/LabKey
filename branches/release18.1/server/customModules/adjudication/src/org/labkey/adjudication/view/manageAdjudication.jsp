<%
/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page import="org.labkey.adjudication.AdjudicationController.ManageSettingsForm"%>
<%@ page import="org.labkey.adjudication.AdjudicationManager" %>
<%@ page import="org.labkey.api.data.Container" %>
<%@ page import="org.labkey.api.security.permissions.AdminPermission" %>
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page import="org.labkey.api.util.PageFlowUtil" %>
<%@ page import="org.labkey.api.admin.AdminUrls" %>
<%@ page import="org.labkey.api.query.QueryAction" %>
<%@ page import="org.labkey.api.query.QueryService" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("Ext4");
        dependencies.add("adjudication/ManageSettings.js");
        dependencies.add("adjudication/Adjudication.css");
    }
%>
<%
    HttpView<ManageSettingsForm> me = (HttpView<ManageSettingsForm>) HttpView.currentView();
    ManageSettingsForm bean = me.getModelBean();
    String prefixText = AdjudicationManager.FILE_NAME_PREFIX.text.name().equals(bean.getPrefixType()) ? bean.getPrefixText() : null;

    Container c = getContainer();
    boolean isAdmin = getViewContext().hasPermission(AdminPermission.class);
    boolean canUpdateSettings = AdjudicationManager.get().getAdjudicationCaseCount(c) == 0;

    ActionURL changeAssayResults = new ActionURL("adjudication", "AssayResultDesigner", c);
    ActionURL configureProperties = PageFlowUtil.urlProvider(AdminUrls.class).getModulePropertiesURL(c);
    ActionURL adjudicationCase = QueryService.get().urlFor(getViewContext().getUser(), c, QueryAction.executeQuery, "adjudication", "adjudicationcase");
%>

<labkey:errors/>
<div id="adjManageLink">
    <p>
        <div class="manage-admin-header">Admin Settings</div>
        <div id="adjManageForm"></div>
    </p>
    <p>
        <div class="manage-admin-header">Assay Result Configuration</div>
        If the assay results file for this study has additional columns,<br/>
        the AssayResults table can be configured to include them.<br/>
        <a class="labkey-text-link" href="<%=changeAssayResults%>">Configure Assay Results</a>
    </p>
    <p>
        <div class="manage-admin-header">Module Properties</div>
        Any admin settings that are configurable throughout the adjudication process, i.e. after initial case</br>
        creation in this folder, will be configured from the Folder Management > Module Properties page.<br/>
        <a class="labkey-text-link" href="<%=configureProperties%>">Configure Properties</a>
    </p>
    <p>
        <div class="manage-admin-header">Adjudication Email Reminders</div>
        Send email reminders to adjudicators regarding cases still awaiting determination.</br>
        <a class="labkey-text-link" href="<%=adjudicationCase%>">Cases</a>
    </p>
</div>

<script type="text/javascript" >
    (function() {
        if (!<%=isAdmin%>) {
            document.getElementById('adjManageLink').style.display = 'none';
        }
        else {
            Ext4.create('LABKEY.adj.ManageSettings', {
                renderTo: 'adjManageForm',
                canUpdateSettings: <%=canUpdateSettings%>,
                prefixType: '<%=h(bean.getPrefixType())%>',
                prefixText: '<%=h(prefixText)%>',
                adjudicatorTeamCount: <%=bean.getAdjudicatorTeamCount()%>,
                requiredDetermination: '<%=h(bean.getRequiredDetermination())%>'
            });
        }
    })();
</script>