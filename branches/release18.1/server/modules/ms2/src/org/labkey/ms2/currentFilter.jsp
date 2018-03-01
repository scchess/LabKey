<%
/*
 * Copyright (c) 2004-2016 Fred Hutchinson Cancer Research Center
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
<%@ page import="org.labkey.api.util.Pair" %>
<%@ page import="org.labkey.ms2.MS2Controller" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%
    MS2Controller.CurrentFilterView.CurrentFilterBean bean = ((MS2Controller.CurrentFilterView) HttpView.currentView()).getModelBean();
%>
  <table><col width="10%"><col width="90%"><%
    if (null != bean.headers)
    {
        for (String header : bean.headers)
        { %>
    <tr><td colspan=2><%=header%></td></tr><%
        } %>
    <tr><td colspan=2>&nbsp;</td></tr><%
    }

    if (null != bean.sqlSummaries)
    {
        for (Pair<String, String> sqlSummary : bean.sqlSummaries)
        { %>
    <tr><td><%=sqlSummary.getKey().replaceAll(" ", "&nbsp;")%>:</td><td><%=h(sqlSummary.getValue())%></td></tr><%
        }
    } %>
  </table>
