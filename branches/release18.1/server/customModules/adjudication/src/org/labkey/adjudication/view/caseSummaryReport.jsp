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
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("Ext4");
    }
%>

<script type="text/javascript">

    (function() {

        // success callback function from selectRows api call: get the case stats and put them into an html table
        function getStats(data)
        {
            var row = data.rows[0];

            // start of the html string for the statistics
            var html = "<table class='labkey-data-region-legacy labkey-show-borders' style='width: 200px;'>";
            html += getStatRowHtml(row, 0, 'TotalCases', 'Total Cases');
            html += getStatRowHtml(row, 1, 'ActiveCases', 'Active');
            html += getStatRowHtml(row, 2, 'CompleteCases', 'Completed');
            html += "</table>";

            html += "<br/><table class='labkey-data-region-legacy labkey-show-borders' style='width: 200px;'>";
            html += getStatRowHtml(row, 0, 'AveCompDays', 'Ave Comp Days');
            html += getStatRowHtml(row, 1, 'MinCompDays', 'Min Comp Days');
            html += getStatRowHtml(row, 2, 'MaxCompDays', 'Max Comp Days');
            html += "</table>";

            html += "<br/><table class='labkey-data-region-legacy labkey-show-borders' style='width: 200px;'>";
            html += getStatRowHtml(row, 0, 'AveReceiptDays', 'Ave Receipt Days');
            html += getStatRowHtml(row, 1, 'MinReceiptDays', 'Min Receipt Days');
            html += getStatRowHtml(row, 2, 'MaxReceiptDays', 'Max Receipt Days');
            html += "</table>";

            Ext4.get('summaryTbl').update(html);
        }

        function getStatRowHtml(row, index, name, label)
        {
            // alternate background shading and bold the header row
            var s = "padding:3px;";
            if (index == 0)
                s += "font-weight:bold;";
            if (index % 2 == 1)
                s += "background-color:#eeeeee;";

            // add the column label and the value to the html table
            var value = row[name], html = "";
            if (value != null)
            {
                html += "<tr><td align='center' style='" + s + "'>" + label + "</td>";
                html += "<td align='right' width='50' style='" + s + "'>" + value + "</td></tr>";
            }

            return html;
        }

        Ext4.onReady(function() {
            // get the adj. statistics from a predefined query
            LABKEY.Query.selectRows({
                schemaName: 'adjudication',
                queryName: 'Case Summary Report',
                successCallback: getStats,
                errorCallback: function(errorInfo, response) {
                    if(errorInfo && errorInfo.exception)
                        alert("ERROR: " + errorInfo.exception);
                    else
                        alert("ERROR: " + response.statusText);
                }
            });
        });
    })();
</script>

<center>
    <div id='summaryTbl'></div>
</center>