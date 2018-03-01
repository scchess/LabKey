<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page import="org.labkey.api.view.HttpView"%>
<%@ page import="org.labkey.api.view.JspView"%>
<%@ page import="org.scharp.atlas.pepdb.PepDBController" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>


<div>
    <%
        JspView<PepDBController.FileForm> me = (JspView<PepDBController.FileForm>) HttpView.currentView();
        PepDBController.FileForm bean = me.getModelBean();
    %>
    <labkey:errors/>
    <labkey:form name="FileForm" action="importPeptides.post" method="POST" enctype="multipart/form-data">
        <table class="normal">
            <tr>
                <td colspan="3">
                    <h4 align="center" style="color:blue">Import Peptides</h4>
                </td>
            </tr>
            <tr>
                <td><th>File Type : </th></td>
                <td><select id="actionType" name="actionType">
                    <option value="" <%=bean.getActionType() == null?" selected" :""%>></option>
                    <option value="PEPTIDES" <%=bean.getActionType() != null && bean.getActionType().equals("PEPTIDES")?" selected":""%>>Peptides</option>
                    <!--<option value="LANL" <%//bean.getActionType() != null && bean.getActionType().equals("LANL")?" selected":""%>>LANL Peptides</option>-->
                    <!--<option value="NONCHILD" <%//bean.getActionType() != null && bean.getActionType().equals("NONCHILD")?" selected":""%>>Non-Child Peptides</option>-->
                    <!--<option value="CHILD" <%//bean.getActionType() != null && bean.getActionType().equals("CHILD")?" selected":""%>>Child Peptides</option>-->
                    <!--<option value="STATUS" <%//bean.getActionType() != null && bean.getActionType().equals("STATUS")?" selected":""%>>Manufacture Status</option>-->
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
        <%= button("Import Peptides").submit(true) %>&nbsp;<%= button("Back").href("begin.view") %>
        <br>
        <h5 style="color:orangered;">
            Note: The File must be .txt extension and It should be tab delimited.<br><br>
        </h5>
    </labkey:form>
</div>
