<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page import="org.labkey.api.view.HttpView"%>
<%@ page import="org.scharp.atlas.pepdb.PepDBController" %>
<%@ page import="org.labkey.api.view.JspView" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>


<div>
    <%
        JspView<PepDBController.FileForm> me = (JspView<PepDBController.FileForm>) HttpView.currentView();
        PepDBController.FileForm bean = me.getModelBean();
    %>

    <% if(null != bean.getMessage()) {%>
        <span style="color: green; font-size: 14px; font-weight:bold"><%=bean.getMessage() %></span>
    <%}%>

    <labkey:errors/>
    <labkey:form name="FileForm" action="importPeptidePools.post" method="POST" enctype="multipart/form-data">
        <table class="normal">
            <tr>
                <td colspan="3">
                    <h4 align="center" style="color:blue">Import Peptide Pools</h4>
                </td>
            </tr>
            <tr>
                <td><th>File Type : </th></td>
                <td><select id="actionType" name="actionType">
                    <option value="" <%=bean.getActionType() == null?" selected" :""%>></option>
                    <option value="POOLDESC" <%=bean.getActionType() != null && bean.getActionType().equals("POOLDESC")?" selected":""%>>Pool Descriptions</option>
                    <option value="POOLPEPTIDES" <%=bean.getActionType() != null && bean.getActionType().equals("POOLPEPTIDES")?" selected":""%>>Peptides in Pool</option>
                </select> 
                </td>
            </tr>
            <tr>
                <td>
                    <th>File : </th>
                </td>
                <td colspan="2">
                    <input type="file" name="pFile" value=""/>
                </td>
            </tr>
        </table>
        <%= button("Import Peptide Pools").submit(true) %>&nbsp;<%= button("Back").href("begin.view") %>
        <br>
        <h5 style="color:orangered;">
            Note: The File must be .txt extension and It should be tab delimited.<br><br>
        </h5>
    </labkey:form>
</div>
