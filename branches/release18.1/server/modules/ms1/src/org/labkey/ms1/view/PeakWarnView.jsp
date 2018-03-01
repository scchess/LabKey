<%
/*
 * Copyright (c) 2007-2013 LabKey Corporation
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
<%@ page import="org.labkey.api.pipeline.PipelineUrls" %>
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.JspView" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%
    JspView me = (JspView)HttpView.currentView();
    ActionURL urlPipeline = urlProvider(PipelineUrls.class).urlBegin(getContainer());
%>
<table class="labkey-peak-warning" width="100%">
    <tr>
        <td>
            <b>Warning:</b> Peak data for these features are still loading, or may have failed to load.
            See the <b><a href="<%=h(urlPipeline)%>">Pipeline status</a></b> for more information.
        </td>
    </tr>
</table>