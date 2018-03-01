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
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.labkey.adjudication.AdjudicationManager" %>
<%@ page import="org.labkey.adjudication.AdjudicationModule" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("clientapi/ext4");
        dependencies.add("adjudication/Adjudication.js");
        dependencies.add("adjudication/AssayDataUpload.js");
    }
%>
<%
    HttpView<AdjudicationModule.UploadWizardForm> me = (HttpView<AdjudicationModule.UploadWizardForm>) HttpView.currentView();
    String filenamePrefix = me.getModelBean().getFilenamePrefix();
    JSONArray allowedFields = me.getModelBean().getAllowedFields();
    boolean hasAllAdjTeamsAssigned = AdjudicationManager.get().hasAllAdjudicatorTeamsAssigned(getContainer());
%>

<style type="text/css">
    table.lk-upload-steps-table td {
        padding: 8px;
    }

    td.normal {
        background-color: #ffffff;
        font-weight:normal }
    td.current {
        background-color: #eeeeee;
        font-weight:bold }
    td.mainArea {
        vertical-align: middle;
        background-color: #eeeeee;
        padding: 20px;
    }
    td.step-title {
        height: 25px;
    }
</style>

<br/>
<div id="adjUploadDiv">
<%
    if (!hasAllAdjTeamsAssigned)
    {
%>
        <div class="labkey-error">
            All adjudicator teams have not been filled. You can proceed with the upload, but the
            Folder Administrator should be notified to assign adjudicators to the empty team(s).
        </div>
        <br/>
<%
    }
%>
    <table class="lk-upload-steps-table">
        <tr>
            <td width='300' id='step1' class='current step-title'></td>
            <td width='500' id='workingArea' rowspan='8' class='mainArea'>
                <div id='status'></div>
                <br/>
                <div id='step1Div'>
                    Click here to browse to an adjudication data file:<br/>
                    <div id='uploadFileButton'></div>
                </div>
                <div id='step2Div' style='display:none'></div>
                <div id='step3Div' style='display:none'></div>
                <div id='attachmentFormDiv' style='display:none'></div>
                <div id='step4Div' style='display:none'></div>
            </td>
        </tr>
        <tr>
            <td id='step2' class='normal step-title'>Step 2</td>
        </tr>
        <tr>
            <td id='step3' class='normal step-title'>Step 3</td>
        </tr>
        <tr>
            <td id='step4' class='normal step-title'>Step 4</td>
        </tr>
        <tr>
            <td class='normal'>&nbsp;</td>
        </tr>
        <tr>
            <td class='normal'>&nbsp;</td>
        </tr>
        <tr>
            <td class='normal'>&nbsp;</td>
        </tr>
        <tr>
            <td class='normal'>&nbsp;</td>
        </tr>
        <tr>
            <td colspan='2' align='right'>
                <input type='button' id='nextButton' class='labkey-button' value='Next'/>&nbsp;
                <input type='button' id='finishButton' class='labkey-button' value='Finish' disabled style='display:none'/>
            </td>
        </tr>
    </table>
</div>
<script type="text/javascript">
    // Used by AssayDataUpload.js
    var uploadConfig = {
        adjFilenamePrefix: '<%=h(filenamePrefix)%>',
        requiredFields: ["PTID", "VISIT", "DRAWDT", "ASSAYKIT", "RESULT"],
        allowedFields: <%= allowedFields %>
    };
</script>