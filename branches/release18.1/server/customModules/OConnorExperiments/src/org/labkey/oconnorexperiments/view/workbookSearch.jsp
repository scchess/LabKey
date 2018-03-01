<%
/*
 * Copyright (c) 2010-2016 LabKey Corporation
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
<%@ page import="org.labkey.api.data.Container" %>
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.oconnorexperiments.OConnorExperimentsController" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("Ext3");
    }
%>
<%
    Container container = getContainer();
%>
<table><tr>
<td>
<form method="GET" action="<%=new ActionURL(OConnorExperimentsController.LookupWorkbookAction.class, container)%>">
    Jump To Experiment: <input type="text" id="wbsearch-id" name="id" size="10" value=""/>
    <%=button("Go").submit(true)%>
</form>
</td><td style="padding-left:20px;">
<form method="GET" action="<%=new ActionURL("search", "search", container)%>">
    Search Experiments: <input type="text" id="wbtextsearch-id" name="q" size="40" value=""/>
    <input type="hidden" name="container" value="<%=h(container.getId())%>"/>
    <input type="hidden" name="includeSubfolders" value="1"/>
    <input type="hidden" name="scope" value="FolderAndSubfolders"/>
    <%=button("Search").submit(true)%>
</form>
</td></tr></table>
<script type="text/javascript">
    Ext.onReady(function(){
        new Ext.form.TextField({
            applyTo: 'wbsearch-id',
            emptyText: 'Enter ID'
        });

        new Ext.form.TextField({
            applyTo: 'wbtextsearch-id',
            emptyText: 'Enter Text'
        });

    });
</script>