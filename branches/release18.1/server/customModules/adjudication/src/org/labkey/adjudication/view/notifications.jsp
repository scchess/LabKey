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
<%@ page import="org.labkey.adjudication.AdjudicationManager" %>
<%@ page import="org.labkey.api.admin.notification.Notification" %>
<%@ page import="org.labkey.api.admin.notification.NotificationService" %>
<%@ page import="org.labkey.api.util.URLHelper" %>
<%@ page import="java.util.List" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%
    List<Notification> notifications = NotificationService.get().getNotificationsByUser(getContainer(), getUser().getUserId(), true);

    // sort notifications by caseId and creation date (i.e. rowId)
    notifications.sort((o1, o2) ->
    {
        if (o1.getObjectId().equals(o2.getObjectId()))
            return o1.getRowId() - o2.getRowId();
        else
            return o1.getObjectId().compareTo(o2.getObjectId());
    });
%>

<ul id="ui-notifications" class="ui-notifications">
<%
    for (Notification notif : notifications)
    {
%>
        <li>
            <span><%=text(notif.getHtmlContent())%></span>
            <%=textLink(notif.getActionLinkText(), notif.getActionLinkURL())%>
<%
            // don't allow quick dismissal of notifications for Lab Personnel to verify case determination receipt
            // or notifications for Adjudicators when case requires resolution
            if (!AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseReadyForVerification.name().equals(notif.getType())
                && !AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseResolutionRequired.name().equals(notif.getType()))
            {
%>
                <%=textLink("dismiss", (URLHelper) null, "removeCaseNotification(" + q(notif.getObjectId()) + ", " + q(notif.getType()) + "); return false;", "removeCaseNotificationId")%>
<%
            }
%>
        </li>
<%
    }
%>
</ul>

<script type="text/javascript">
    function removeCaseNotification(caseId, notifType)
    {
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('adjudication', 'removeCaseNotifications'),
            method: 'POST',
            jsonData: {
                adjid: caseId,
                notificationType: notifType
            },
            success: function (response)
            {
                window.location.reload();
            },
            failure: function(response)
            {
                var msg = response.status == 403 ? response.statusText : Ext4.JSON.decode(response.responseText).exception;
                Ext4.Msg.show({
                    title:'Error',
                    msg: msg,
                    buttons: Ext4.Msg.OK,
                    icon: Ext4.Msg.ERROR
                });
            },
            scope: this
        });
    }
</script>