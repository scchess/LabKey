<%
/*
 * Copyright (c) 2011-2012 LabKey Corporation
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
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.core.security.SecurityController" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%
    String caption;
    SecurityController.FolderAccessForm form = (SecurityController.FolderAccessForm) HttpView.currentModel();
    ActionURL url = getViewContext().cloneActionURL();

    if (!form.showAll())
    {
        url.addParameter("showAll", true);
        caption = form.getShowCaption();
    }
    else
    {
        url.deleteParameter("showAll");
        caption = form.getHideCaption();
    }
%>
<table>
    <tr>
        <td>
            <%=textLink(caption, url)%>
        </td>
    </tr>
</table>
