<%
/*
 * Copyright (c) 2011-2017 LabKey Corporation
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
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%
    ActionURL url = (ActionURL)HttpView.currentModel();
%>
<table class="lk-fields-table">
    <tr>
        <td>
            <table class="labkey-export-tab-layout"><tr><td>Export sample set definition as a XAR file</td></tr></table>
        </td>
    </tr>
    <tr>
        <td>
            <%= button("Export to XAR").href(url) %>
        </td>
    </tr>
</table>
