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
package org.labkey.adjudication;

import org.apache.commons.lang3.EnumUtils;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;
import org.labkey.adjudication.data.AssayType;
import org.labkey.adjudication.data.CaseDocument;
import org.labkey.api.admin.notification.Notification;
import org.labkey.api.admin.notification.NotificationService;
import org.labkey.api.attachments.AttachmentFile;
import org.labkey.api.attachments.AttachmentService;
import org.labkey.api.cache.BlockingStringKeyCache;
import org.labkey.api.cache.CacheManager;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Filter;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.exp.property.DomainProperty;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.settings.LookAndFeelProperties;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.ConfigurationException;
import org.labkey.api.util.GUID;
import org.labkey.api.util.MailHelper;
import org.labkey.api.view.ActionURL;

import javax.mail.Message;
import javax.mail.internet.InternetAddress;
import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;

public class AdjudicationManager
{
    private static final AdjudicationManager INSTANCE = new AdjudicationManager();

    public static AdjudicationManager get()
    {
        return INSTANCE;
    }

    private AdjudicationSchema _adj;
    private Logger _log;

    private AdjudicationManager()
    {
        _adj = AdjudicationSchema.getInstance();
        _log = Logger.getLogger("Adjudication");
    }

    public AttachmentService getAttachmentService()
    {
        return AttachmentService.get();
    }

    public String updateAttachments(User user, AdjudicationAssayResultAttachmentParent parent, List<String> deleteNames, List<AttachmentFile> files) throws IOException
    {
        String message = null;

        AttachmentService attSvc = getAttachmentService();

        //delete the attachments requested
        if (null != deleteNames && !deleteNames.isEmpty())
        {
            for (String name : deleteNames)
            {
                attSvc.deleteAttachment(parent, name, user);
            }
        }

        //add any files as attachments
        if (null != files && files.size() > 0)
        {
            try
            {
                attSvc.addAttachments(parent, files, user);
            }
            catch (AttachmentService.DuplicateFilenameException e)
            {
                message = e.getMessage();
            }
            catch (IOException e)
            {
                message = e.getMessage() == null ? e.toString() : e.getMessage();
            }
        }

        return message;
    }

    public AdjudicationAssayResultAttachmentParent getAssayResultAttachmentParent(@NotNull Container c, User user, int rowId)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("RowId"), rowId);
        return getAssayResultAttachmentParent(c, user, filter);
    }

    public AdjudicationAssayResultAttachmentParent getAssayResultAttachmentParent(@NotNull Container c, User user, String entityId)
    {
        Filter filter = new SimpleFilter(FieldKey.fromParts("EntityId"), entityId);
        return getAssayResultAttachmentParent(c, user, filter);
    }

    private AdjudicationAssayResultAttachmentParent getAssayResultAttachmentParent(@NotNull Container c, User user, Filter filter)
    {
        Selector selector = new TableSelector(_adj.getTableInfoAssayResults(c, user).getColumn("EntityId"), filter, null);
        String entityId = selector.getObject(String.class);

        return new AdjudicationAssayResultAttachmentParent(c, entityId);
    }

    public void deleteAdjudicationData(Container container, User user) throws SQLException
    {
        DbScope scope = _adj.getSchema().getScope();
        SimpleFilter containerFilter = SimpleFilter.createContainerFilter(container);
        try (DbScope.Transaction transaction = scope.ensureTransaction())
        {
            _adj.deleteAssayResultsTable(container, user);
            Table.delete(_adj.getTableInfoDetermination(), containerFilter);
            Table.delete(_adj.getTableInfoVisit(), containerFilter);
            Table.delete(_adj.getTableInfoAdjudicationCase(), containerFilter);
            Table.delete(_adj.getTableInfoStatus(), containerFilter);
            Table.delete(_adj.getTableInfoSupportedKits(), containerFilter);
            Table.delete(_adj.getTableInfoAdjudicationTeamUser(), containerFilter);
            Table.delete(_adj.getTableInfoAdjudicationUser(), containerFilter);
            Table.delete(_adj.getTableInfoCaseDocuments(), containerFilter);
            Table.delete(_adj.getTableInfoAssayType(), containerFilter);
            transaction.commit();
        }
    }

    public void notifyOfCaseUpdate(Container container, User user, int caseId, boolean isCreate) throws ValidationException
    {
        String type = isCreate ? NOTIFICATION_TYPE.AdjudicationCaseCreated.name() : NOTIFICATION_TYPE.AdjudicationCaseAssayDataUpdated.name();
        String subject = isCreate ? NOTIFICATION_TYPE.AdjudicationCaseCreated.getTitle() : NOTIFICATION_TYPE.AdjudicationCaseAssayDataUpdated.getTitle();
        String description = isCreate ? "A new adjudication case, #" + caseId + ", has been created"
                                      : "Assay data for case #" + caseId + " has been updated";
        String emailBody = description + " for " + getProtocolInfoStr(container) + ".";

        // create UI notifications to use in the 'Notifications' webpart on the dashboard
        Notification uiNotification = new Notification();
        uiNotification.setObjectId("" + caseId);
        uiNotification.setType(type);
        uiNotification.setDescription(description + ".");
        uiNotification.setActionLinkText("view");

        // the action url is slightly different for the different roles
        ActionURL determinationUrl = getDeterminationUrl(container, caseId);
        ActionURL reviewUrl = getReviewUrl(container, caseId, true);

        for (User recipient : getNotificationUsersForRole(container, AdjudicationUserTable.ADJUDICATOR))
        {
            // remove any notifications related to this user/objectid/type
            NotificationService.get().removeNotifications(container, uiNotification.getObjectId(), Collections.singletonList(type), recipient.getUserId());

            uiNotification.setUserId(recipient.getUserId());
            uiNotification.setActionLinkURL(determinationUrl.getLocalURIString());
            NotificationService.get().addNotification(container, user, uiNotification);
        }
        for (User recipient : getNotificationUsersForRoles(container, Arrays.asList(AdjudicationUserTable.FOLDERADMIN, AdjudicationUserTable.LABPERSONNEL)))
        {
            NotificationService.get().removeNotifications(container, uiNotification.getObjectId(), Collections.singletonList(type), recipient.getUserId());

            uiNotification.setUserId(recipient.getUserId());
            uiNotification.setActionLinkURL(reviewUrl.getLocalURIString());
            NotificationService.get().addNotification(container, user, uiNotification);
        }

        // send email notifications as well
        List<String> nonAdminRolesToNotify = Arrays.asList(AdjudicationUserTable.ADJUDICATOR);
        sendEmailNotification(container, user, subject, emailBody, getNotificationUsersForRoles(container, nonAdminRolesToNotify), determinationUrl, true);

        List<String> adminRolesToNotify = Arrays.asList(AdjudicationUserTable.FOLDERADMIN,
                AdjudicationUserTable.LABPERSONNEL, AdjudicationUserTable.TOBENOTIFIED, AdjudicationUserTable.DATAREVIEWER);
        sendEmailNotification(container, user, subject, emailBody, getNotificationUsersForRoles(container, adminRolesToNotify), reviewUrl, true);
    }

    public void notifyOfDeterminationUpdate(Container container, User user, int caseId, boolean isComplete, boolean confirmedInfection) throws ValidationException
    {
        String subject = isComplete ? NOTIFICATION_TYPE.AdjudicationCaseCompleted.getTitle()
                                    : NOTIFICATION_TYPE.AdjudicationCaseDeterminationUpdated.getTitle();
        String description = isComplete ? "Adjudication case #" + caseId + " has been completed"
                                        : "Adjudication case #" + caseId + " has an updated determination";
        String emailBody = description + " for " + getProtocolInfoStr(container) + ".";

        ActionURL adminReviewUrl = getReviewUrl(container, caseId, true);
        ActionURL nonAdminReviewUrl = getReviewUrl(container, caseId, false);

        // create UI notifications to use in the 'Notifications' webpart on the dashboard for case completion
        if (isComplete)
        {
            Notification uiNotification = new Notification();
            uiNotification.setObjectId("" + caseId);
            uiNotification.setActionLinkText("view");
            uiNotification.setActionLinkURL(adminReviewUrl.getLocalURIString());

            // Note: the description is slightly different for the different roles
            for (User recipient : getNotificationUsersForRole(container, AdjudicationUserTable.LABPERSONNEL))
            {
                uiNotification.setUserId(recipient.getUserId());
                uiNotification.setType(NOTIFICATION_TYPE.AdjudicationCaseReadyForVerification.name());
                uiNotification.setDescription(description + ", but the lab has not yet verified that they have received the data.");
                NotificationService.get().addNotification(container, user, uiNotification);
            }

            // notify users of case complete, infection monitors are only notified if there is a confirmed infection
            List<String> notificationUsers = new ArrayList<>();
            notificationUsers.add(AdjudicationUserTable.FOLDERADMIN);
            if (confirmedInfection)
                notificationUsers.add(AdjudicationUserTable.INFECTIONMONITOR);

            for (User recipient : getNotificationUsersForRoles(container, notificationUsers))
            {
                uiNotification.setUserId(recipient.getUserId());
                uiNotification.setType(NOTIFICATION_TYPE.AdjudicationCaseCompleted.name());
                uiNotification.setDescription(description + ".");
                NotificationService.get().addNotification(container, user, uiNotification);
            }
        }

        // send email notifications as well
        List<String> rolesToNotify = new ArrayList<>();
        rolesToNotify.addAll(Arrays.asList(AdjudicationUserTable.FOLDERADMIN, AdjudicationUserTable.LABPERSONNEL, AdjudicationUserTable.TOBENOTIFIED));
        if (!isComplete)
            rolesToNotify.add(AdjudicationUserTable.DATAREVIEWER);
        else if (isComplete && confirmedInfection)
            rolesToNotify.add(AdjudicationUserTable.INFECTIONMONITOR);

        sendEmailNotification(container, user, subject, emailBody, getNotificationUsersForRoles(container, rolesToNotify), adminReviewUrl, true);

        if (isComplete)
        {
            sendEmailNotification(container, user, subject, emailBody, getNotificationUsersForRoles(container,
                    Collections.singletonList(AdjudicationUserTable.ADJUDICATOR)), nonAdminReviewUrl, true);
        }
    }

    public void notifyOfResolutionRequired(Container container, User user, int caseId) throws ValidationException
    {
        String subject = NOTIFICATION_TYPE.AdjudicationCaseResolutionRequired.getTitle();
        String description = "Adjudication case #" + caseId + " requires resolution";
        String emailBody = description + " for " + getProtocolInfoStr(container) + ".";
        ActionURL determinationUrl = getDeterminationUrl(container, caseId);

        // create UI notifications to use in the 'Notifications' webpart on the dashboard
        Notification uiNotification = new Notification();
        uiNotification.setObjectId("" + caseId);
        uiNotification.setActionLinkText("view");
        uiNotification.setActionLinkURL(determinationUrl.getLocalURIString());
        uiNotification.setType(NOTIFICATION_TYPE.AdjudicationCaseResolutionRequired.name());
        uiNotification.setDescription(description + ".");

        for (User recipient : getNotificationUsersForRole(container, AdjudicationUserTable.ADJUDICATOR))
        {
            uiNotification.setUserId(recipient.getUserId());
            // check if this notification already exists before trying to add it
            if (NotificationService.get().getNotification(container, uiNotification) == null)
                NotificationService.get().addNotification(container, user, uiNotification);
        }

        // send email notifications as well
        sendEmailNotification(container, user, subject, emailBody,
                getNotificationUsersForRoles(container, Collections.singletonList(AdjudicationUserTable.ADJUDICATOR)),
                determinationUrl, false);
    }

    public void emailAllAdjudicationContainersReminders()
    {
        // get list of all containers that are adjudication containers
        Set<Container> allContainers = ContainerManager.getAllChildren(ContainerManager.getRoot());
        allContainers.forEach(container -> {
            if (container.hasActiveModuleByName("Adjudication"))
            {
                // send reminder emails to adjudicators of cases in this container
                // but only if the Module Property for sending reminders is turned on for this container
                if (getAutomaticRemindersModuleProperty(container).equalsIgnoreCase("TRUE"))
                {
                    emailAllCasesReminders(container);
                }
            }
        });
     }

    private void emailAllCasesReminders(Container container)
    {
        // get list of all cases that are open and for each case send out reminder emails to adjudicators
        SimpleFilter filter = SimpleFilter.createContainerFilter(container);
        filter.addCondition(FieldKey.fromParts("Completed"), null, CompareType.DATE_EQUAL);
        TableSelector selector = new TableSelector(_adj.getTableInfoAdjudicationCase(), Collections.singleton("CaseId"), filter, null);
        List<Integer> caseIds = selector.getArrayList(Integer.class);
        caseIds.forEach( caseId -> {
            emailCaseReminders(container, caseId);
        });
    }

    public void emailCaseReminders(Container container, int caseId)
    {
        // Find the adjudicators for this case who have not completed their work
        List<String> adjudicatorRoles = Collections.singletonList(AdjudicationUserTable.ADJUDICATOR);
        List<User>  allAdjudicators = getNotificationUsersForRoles(container, adjudicatorRoles);
        List<Integer> notFinishedCaseUsersIds = getCaseUsersNotFinished(container, caseId);
        List<User> notFinishedCaseAdjudicators = new ArrayList<User>();
        allAdjudicators.forEach( adjudicator -> {
            if (notFinishedCaseUsersIds.contains(adjudicator.getUserId()))
                notFinishedCaseAdjudicators.add(adjudicator);
        });
        // All adjudicators for this case have finished, but this case is still active. The case is active
        // because the adjudicators disagreed and still need to come to a resolution. Send reminders regarding need
        // for resolution to all adjudicators for this container.
        boolean isRequiresResolution = false;
        if (null == notFinishedCaseAdjudicators || notFinishedCaseAdjudicators.size() == 0)
        {
            notFinishedCaseAdjudicators.addAll(allAdjudicators);
            isRequiresResolution = true;
        }
        String subject = isRequiresResolution ? NOTIFICATION_TYPE.AdjudicationCaseResolutionReminder.getTitle()
                : NOTIFICATION_TYPE.AdjudicationCaseNeedsDetermination.getTitle();
        String description = isRequiresResolution ? "Reminder that adjudication case #" + caseId + " requires resolution"
                : "Reminder that adjudication case #" + caseId + " needs determination";
        String emailBody = description + " for " + getProtocolInfoStr(container) + ".";
        ActionURL determinationUrl = getDeterminationUrl(container, caseId);

        if (null != notFinishedCaseAdjudicators && notFinishedCaseAdjudicators.size() > 0) {
            sendEmailNotification(container, null, subject, emailBody,
                    notFinishedCaseAdjudicators,
                    determinationUrl, false);
        }
    }

    private String getProtocolInfoStr(Container container)
    {
        String protocolInfo = AdjudicationManager.get().getProtocolNameModuleProperty(container);
        return protocolInfo != null ? protocolInfo : container.getPath();
    }

    private List<User> getNotificationUsersForRoles(Container container, List<String> roles)
    {
        List<User> recipients = new ArrayList<>();
        for (String roleName : roles)
            recipients.addAll(getNotificationUsersForRole(container, roleName));
        return recipients;
    }

    private void sendEmailNotification(Container container, User user, String subject, String body, List<User> recipients,
                                       ActionURL reviewUrl, boolean asIndividual)
    {
        if (asIndividual)
        {
            for (User recipient : recipients)
                sendEmailNotification(container, user, subject, body, Collections.singletonList(recipient), reviewUrl);
        }
        else
        {
            sendEmailNotification(container, user, subject, body, recipients, reviewUrl);
        }
    }

    private void sendEmailNotification(Container container, User user, String subject, String body, List<User> recipients, ActionURL reviewUrl)
    {
        try
        {
            String subjectPrefix = AdjudicationManager.get().getProtocolNameModuleProperty(container);
            subjectPrefix = subjectPrefix != null ? subjectPrefix + " - " : "";

            List<InternetAddress> addresses = new ArrayList<>();
            for (User recipient : recipients)
                addresses.add(new InternetAddress(recipient.getEmail()));

            if (null != reviewUrl)
                body += " View assay results: " + reviewUrl.getURIString();

            MailHelper.ViewMessage message = MailHelper.createMessage();
            message.setFrom(LookAndFeelProperties.getInstance(container).getSystemEmailAddress());
            message.setRecipients(Message.RecipientType.TO, addresses.toArray(new InternetAddress[addresses.size()]));
            message.setSubject(subjectPrefix + subject);
            message.setText(body);
            MailHelper.send(message, user, container);
        }
        catch (javax.mail.MessagingException | ConfigurationException | NullPointerException e)
        {
            _log.warning("Notification Error: " + e.getMessage());
        }
    }

    public List<User> getNotificationUsersForRole(Container container, String roleName)
    {
        SimpleFilter filter = SimpleFilter.createContainerFilter(container);
        filter.addCondition(FieldKey.fromParts("RoleId"), AdjudicationUserTable.getAdjudicationRole(roleName));
        TableSelector selector = new TableSelector(_adj.getTableInfoAdjudicationUser(),
                Collections.singleton(AdjudicationUserTable.USERID), filter, null);

        List<User> users = new ArrayList<>();
        for (Integer userId : selector.getArray(Integer.class))
        {
            User user = UserManager.getUser(userId);
            if (user != null && user.isActive()) // Issue 29403: don't send notifications to inactive users
            {
                if(roleName.equals(AdjudicationUserTable.ADJUDICATOR)){
                    if(!getAdjudicatorNotifyStatus(container, user.getUserId())){
                        continue;
                    }
                }
                users.add(user);
            }
        }
        return users;
    }

    private ActionURL getReviewUrl(Container container, int caseId, boolean isAdminReview)
    {
        ActionURL url = new ActionURL(AdjudicationController.AdjudicationReviewAction.class, container);
        url.addParameter("adjid", caseId);
        url.addParameter("isAdminReview", isAdminReview);
        return url;
    }

    private ActionURL getDeterminationUrl(Container container, int caseId)
    {
        ActionURL url = new ActionURL(AdjudicationController.AdjudicationDeterminationAction.class, container);
        url.addParameter("adjid", caseId);
        return url;
    }

    private Integer getAdjudicationUserId(Container container, int userId)
    {
        SimpleFilter filter = SimpleFilter.createContainerFilter(container);
        filter.addCondition(FieldKey.fromParts(AdjudicationUserTable.USERID), userId);
        TableSelector selector = new TableSelector(_adj.getTableInfoAdjudicationUser(), Collections.singleton("RowId"), filter, null);
        return selector.getObject(Integer.class);
    }

    public Integer getAdjudicatorTeamNumber(Container container, int userId)
    {
        Integer adjUserId = getAdjudicationUserId(container, userId);
        if (adjUserId != null)
        {
            SimpleFilter filter = SimpleFilter.createContainerFilter(container);
            filter.addCondition(FieldKey.fromParts(AdjudicationTeamUserTable.ADJUDICATIONUSERID), adjUserId);
            TableSelector selector = new TableSelector(_adj.getTableInfoAdjudicationTeamUser(), Collections.singleton("TeamNumber"), filter, null);
            return selector.getObject(Integer.class);
        }
        else
        {
            return null;
        }
    }

    public Boolean getAdjudicatorNotifyStatus(Container container, int userId)
    {
        Integer adjUserId = getAdjudicationUserId(container, userId);
        if (adjUserId != null)
        {
            SimpleFilter filter = SimpleFilter.createContainerFilter(container);
            filter.addCondition(FieldKey.fromParts(AdjudicationTeamUserTable.ADJUDICATIONUSERID), adjUserId);
            TableSelector selector = new TableSelector(_adj.getTableInfoAdjudicationTeamUser(), Collections.singleton("Notify"), filter, null);
            return selector.getObject(Boolean.class);
        }
        else
        {
            return true;
        }
    }

    public List<Integer> getCaseUsersNotFinished(Container container,  int caseId)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("CaseId"), caseId);
        filter.addCondition(FieldKey.fromString("Status"), "pending");
        TableInfo adjudicationUserInfoTable = _adj.getTableInfoAdjudicationUser();
        TableInfo adjudicationTeamUserInfoTable = _adj.getTableInfoAdjudicationTeamUser();
        TableInfo determinationInfoTable = _adj.getTableInfoDetermination();

        SQLFragment userNotFinishedSQL = new SQLFragment();
        userNotFinishedSQL.append("SELECT userid FROM ")
                .append(adjudicationUserInfoTable.getFromSQL("au"))
                .append(" LEFT OUTER JOIN ")
                .append(adjudicationTeamUserInfoTable.getFromSQL("atu")).append(" ON au.RowId=atu.AdjudicationUserId")
                .append(" LEFT OUTER JOIN ")
                .append(determinationInfoTable.getFromSQL("d")).append(" ON atu.TeamNumber=d.TeamNumber")
                .append( " WHERE d.CaseId=" + caseId + " AND d.Status='pending'  AND d.container=?");
        userNotFinishedSQL.add(container);

        SqlSelector selector = new SqlSelector(_adj.getSchema(), userNotFinishedSQL);
        List<Integer> userIds = selector.getArrayList(Integer.class);
        return  userIds;
    }

    public int removeAdjudicatorTeamMember(Container container, int adjUserId)
    {
        SimpleFilter filter = SimpleFilter.createContainerFilter(container);
        filter.addCondition(FieldKey.fromParts(AdjudicationTeamUserTable.ADJUDICATIONUSERID), adjUserId);
        return Table.delete(_adj.getTableInfoAdjudicationTeamUser(), filter);
    }

    public int removeAdjudicatorTeamMembers(Container container, int teamNumber)
    {
        SimpleFilter filter = SimpleFilter.createContainerFilter(container);
        filter.addCondition(FieldKey.fromParts(AdjudicationTeamUserTable.TEAMNUMBER), teamNumber);
        return Table.delete(_adj.getTableInfoAdjudicationTeamUser(), filter);
    }

    public long getAdjudicationCaseCount(Container container)
    {
        return new TableSelector(_adj.getTableInfoAdjudicationCase(), SimpleFilter.createContainerFilter(container), null).getRowCount();
    }

    public boolean hasAllAdjudicatorTeamsAssigned(Container container)
    {
        SQLFragment sql = new SQLFragment("SELECT DISTINCT TeamNumber FROM ");
        sql.append(_adj.getTableInfoAdjudicationTeamUser(), "a");
        sql.append(" WHERE Container = ?").add(container);
        SqlSelector selector = new SqlSelector(AdjudicationSchema.getInstance().getSchema(), sql);
        return getNumberOfAdjudicatorTeams(container) == selector.getArrayList(String.class).size();
    }

    public Map<String, Object> insertCase(User user, Container container, AdjudicationController.CreateAdjudicationForm form, Integer statusId)
    {
        Map<String, Object> caseMap = new HashMap<>();
        caseMap.put("ParticipantId", form.getParticipantId());
        caseMap.put("StatusId", statusId);
        caseMap.put("Created", new Date());
        caseMap.put("Notified", false);
        caseMap.put("AssayFileName", form.getAssayFilename());
        caseMap.put("Comment", form.getComment());
        caseMap.put("NewData", false);
        caseMap.put("Container", container);
        return Table.insert(user, AdjudicationSchema.getInstance().getTableInfoAdjudicationCase(), caseMap);
    }

    public Map<String, Object> insertDetermination(User user, Container container, int caseId, int team)
    {
        Map<String, Object> detMap = new HashMap<>();
        detMap.put("CaseId", caseId);
        detMap.put("Status", "pending");
        detMap.put("LastUpdated", new Date());
        detMap.put("LastUpdatedBy", user.getEmail());
        detMap.put("Container", container);
        detMap.put("TeamNumber", team);
        return Table.insert(user, AdjudicationSchema.getInstance().getTableInfoDetermination(), detMap);
    }

    public Map<String, Object> insertStatus(User user, Container container, String status, int order)
    {
        Map<String, Object> map = new HashMap<>();
        map.put("Status", status);
        map.put("SequenceOrder", order);
        map.put("Container", container);
        return Table.insert(user, AdjudicationSchema.getInstance().getTableInfoStatus(), map);
    }

    public Map<String, Object> insertVisit(User user, Container container, int caseId, double visit)
    {
        Map<String, Object> visitMap = new HashMap<>();
        visitMap.put("CaseId", caseId);
        visitMap.put("Visit", visit);
        visitMap.put("Container", container);

        SimpleFilter filter = SimpleFilter.createContainerFilter(container);
        filter.addCondition(FieldKey.fromString("CaseId"), caseId);
        filter.addCondition(FieldKey.fromString("Visit"), visit);
        Map<String, Object>[] existingVisit = new TableSelector(AdjudicationSchema.getInstance().getTableInfoVisit(), filter, null).getMapArray();
        if (existingVisit.length == 0)
        {
            return Table.insert(user, AdjudicationSchema.getInstance().getTableInfoVisit(), visitMap);
        }

        return null;
    }

    @Nullable
    public CaseDocument insertCaseDocument(User user, Container container, int caseId, AttachmentFile document) throws IOException
    {
        if (document != null && document.getSize() > 0)
        {
            CaseDocument caseDocument = new CaseDocument();

            caseDocument.beforeInsert(user, container.getId());
            caseDocument.setCaseId(caseId);
            caseDocument.setDocument(document);
            caseDocument.setDocumentName(document.getFilename());

            return Table.insert(user, AdjudicationSchema.getInstance().getTableInfoCaseDocuments(), caseDocument);
        }
        else
            return null;
    }

    public Map<String, Object> convertAssayResult(int caseId, JSONObject rowData, Container container) throws ParseException
    {
        Map<String, Object> map = new HashMap<>();
        for (Map.Entry<String, Object> entry : rowData.entrySet())
        {
            String key = AssayResultsDomainKind.translateColumnName(entry.getKey());
            Object value = AssayResultsDomainKind.translateDate(key, entry.getValue());
            map.put(key, value);
        }
        map.put("CaseId", caseId);
        return map;
    }

    public Map<String, Object> insertAssayResult(User user, Container container, Map<String, Object> rowData) throws ParseException
    {
        rowData.put("EntityId", GUID.makeGUID());
        return Table.insert(user, AdjudicationSchema.getInstance().getTableInfoAssayResults(container, user), rowData);
    }

    public Map<String, Object> updateAssayResult(User user, Container container, Map<String, Object> rowData, int rowId) throws ParseException
    {
        return Table.update(user, AdjudicationSchema.getInstance().getTableInfoAssayResults(container, user), rowData, rowId);
    }

    private static final String SETTINGS_PROPERTY_NAME = "Adjudication-filename-prefix"; // TODO how to change this if properties already stored in a production server?
    private static final String SETTINGS_PREFIX_TYPE = "prefix";
    private static final String SETTINGS_PREFIX_TEXT = "text";
    private static final String SETTINGS_ADJUDICATOR_TEAM_COUNT = "adjudicatorSlots";
    private static final String SETTINGS_REQUIRED_DETERMINATION = "requiredDetermination";

    public AdjudicationController.ManageSettingsForm getManageSettingsProperties(Container container)
    {
        AdjudicationController.ManageSettingsForm form = new AdjudicationController.ManageSettingsForm();
        PropertyManager.PropertyMap map = PropertyManager.getProperties(container, SETTINGS_PROPERTY_NAME);

        String prefix = map.get(SETTINGS_PREFIX_TYPE);
        form.setPrefixType(prefix != null ? prefix : FILE_NAME_PREFIX.folderName.name());
        form.setPrefixText(map.get(SETTINGS_PREFIX_TEXT));

        String teamsStr = map.get(SETTINGS_ADJUDICATOR_TEAM_COUNT);
        form.setAdjudicatorTeamCount(teamsStr == null ? 2 : Integer.parseInt(teamsStr));

        String determType = map.get(SETTINGS_REQUIRED_DETERMINATION);
        form.setRequiredDetermination(determType != null ? determType : REQUIRED_DETERMINATION.hiv1Only.name());

        return form;
    }

    public void setManageSettingsProperties(Container container, AdjudicationController.ManageSettingsForm form)
    {
        // only allow settings to be changed if no cases have been entered in this container
        if (getAdjudicationCaseCount(container) > 0)
            throw new IllegalStateException("Cannot change Admin manage settings after an adjudication case has been created.");

        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(container, SETTINGS_PROPERTY_NAME, true);

        FILE_NAME_PREFIX prefixType = FILE_NAME_PREFIX.valueOf(form.getPrefixType());
        map.put(SETTINGS_PREFIX_TYPE, prefixType.name());

        String prefixText = FILE_NAME_PREFIX.text == prefixType ? form.getPrefixText() : null;
        map.put(SETTINGS_PREFIX_TEXT, prefixText);

        map.put(SETTINGS_ADJUDICATOR_TEAM_COUNT, String.valueOf(form.getAdjudicatorTeamCount()));

        REQUIRED_DETERMINATION determType = REQUIRED_DETERMINATION.valueOf(form.getRequiredDetermination());
        map.put(SETTINGS_REQUIRED_DETERMINATION, determType.name());

        map.save();
    }

    public boolean requiresHiv1Determination(Container container)
    {
        String determType = getManageSettingsProperties(container).getRequiredDetermination();
        return !REQUIRED_DETERMINATION.hiv2Only.name().equals(determType);
    }

    public boolean requiresHiv2Determination(Container container)
    {
        String determType = getManageSettingsProperties(container).getRequiredDetermination();
        return !REQUIRED_DETERMINATION.hiv1Only.name().equals(determType);
    }

    public int getNumberOfAdjudicatorTeams(Container container)
    {
        return getManageSettingsProperties(container).getAdjudicatorTeamCount();
    }

    // Returns null if there is a problem, such as no study name
    @Nullable
    public String getFilenamePrefix(Container container)
    {
        AdjudicationController.ManageSettingsForm form = getManageSettingsProperties(container);
        return getFilenamePrefix(container, form.getPrefixType(), form.getPrefixText());
    }

    @Nullable
    public String getFilenamePrefix(Container container, String prefix, String text)
    {
        if (!EnumUtils.isValidEnum(FILE_NAME_PREFIX.class, prefix))
        {
            return null;
        }

        FILE_NAME_PREFIX prefixType = FILE_NAME_PREFIX.valueOf(prefix);
        if (FILE_NAME_PREFIX.studyName == prefixType)
        {
            Container parent = container.getParent();
            StudyService studyService = StudyService.get();
            if (null != parent && null != studyService)
            {
                Study study = studyService.getStudy(parent);
                return null != study ? study.getLabel() : null;
            }
            return null;
        }
        else if (FILE_NAME_PREFIX.folderName == prefixType)
        {
            Container parent = container.getParent();
            if (null != parent && !parent.isRoot())
                return parent.getName();
            return null;
        }
        else
        {
            // make sure to return blank instead of null
            return text != null ? text : "";
        }
    }

    public List<String> getAllowedAssayResultFields(Container container)
    {
        List<String> fieldsToNotInclude = Arrays.asList(
            "participantid", "visit", "assaykit", "drawdate",
            "result", "rowid", "entityid", "caseid"
        );

        // Returns array of field names, not including the required ones
        Domain assayResultsDomain = _adj.ensureAssayResultsDomain(container, null);
        List<String> allowedFields = new ArrayList<>();
        for (DomainProperty prop : assayResultsDomain.getProperties())
        {
            String name = prop.getName();
            if (!fieldsToNotInclude.contains(name.toLowerCase()))
                allowedFields.add(AssayResultsDomainKind.reverseTranslateColumnName(name).toUpperCase());
        }

        // Legacy: input files have PROTOCOL, but we don't retain it by default in AssayResults
        if (!allowedFields.contains("PROTOCOL"))
            allowedFields.add("PROTOCOL");

        return allowedFields;
    }

    public String getProtocolNameModuleProperty(Container c)
    {
        Module module = ModuleLoader.getInstance().getModule(AdjudicationModule.NAME);
        return module.getModuleProperties().get(AdjudicationModule.PROTOCOL_NAME_PROPERTY).getEffectiveValue(c);
    }

    public String getAutomaticRemindersModuleProperty(Container c)
    {
        Module module = ModuleLoader.getInstance().getModule(AdjudicationModule.NAME);
        return module.getModuleProperties().get(AdjudicationModule.AUTOMATIC_REMINDERS_PROPERTY).getEffectiveValue(c);
    }

    public enum FILE_NAME_PREFIX
    {
        studyName,
        folderName,
        text
    }

    public enum REQUIRED_DETERMINATION
    {
        both,
        hiv1Only,
        hiv2Only
    }

    public enum NOTIFICATION_TYPE
    {
        AdjudicationCaseCreated("Adjudication Case Created"),
        AdjudicationCaseAssayDataUpdated("Adjudication Case Assay Data Updated"),
        AdjudicationCaseCompleted("Adjudication Case Completed"),
        AdjudicationCaseDeterminationUpdated("Adjudication Case Determination Updated"),
        AdjudicationCaseReadyForVerification("Adjudication Case Ready for Verification"),
        AdjudicationCaseResolutionRequired("Adjudication Case Resolution Required"),
        AdjudicationCaseResolutionReminder("Reminder - Adjudication Case Resolution Required"),
        AdjudicationCaseNeedsDetermination("Reminder - Adjudication Case Needs Determination");
        private final String _title;

        NOTIFICATION_TYPE(String title)
        {
            _title = title;
        }

        public String getTitle()
        {
            return _title;
        }
    }

    public void setDefaultAssayTypes(final Container container, final User user) throws Exception
    {
        Container rootContainer = ContainerManager.getRoot();
        if (rootContainer.equals(container))
        {
            _log.warning("Cannot set assay type defaults on root container");
            return;
        }

        final TableInfo tableInfo = AdjudicationSchema.getInstance().getTableInfoAssayType();
        try (DbScope.Transaction transaction = tableInfo.getSchema().getScope().ensureTransaction())
        {
            Set<String> columnNames = new HashSet<>(2);
            columnNames.add("Name");
            columnNames.add("Label");
            SimpleFilter filter = SimpleFilter.createContainerFilter(rootContainer);
            new TableSelector(AdjudicationSchema.getInstance().getTableInfoAssayType(), columnNames, filter, null)
                    .forEachMap(row ->
                    {
                        row.put("Container", container.getEntityId());
                        Table.insert(user, tableInfo, row);
                    });
            transaction.commit();
        }
        clearAssayTypesCache(container);
    }

    // Cache by container of case-insensitive map assayTypeName -> row
    private BlockingStringKeyCache<Map<String, AssayType>> _assayTypesCache =
            CacheManager.getBlockingStringKeyCache(100, CacheManager.DAY * 7, "Assay Types Cache", (String key, Object argument) ->
            {
                if (null == argument)
                    return Collections.emptyMap();
                final Map<String, AssayType> assayTypes = new CaseInsensitiveHashMap<>();
                new TableSelector(AdjudicationSchema.getInstance().getTableInfoAssayType(),
                                  SimpleFilter.createContainerFilter((Container)argument),
                                  null)
                        .getArrayList(AssayType.class).forEach(assayType ->
                        {
                            assayTypes.put(assayType.getName(), assayType);
                        });
                return assayTypes;
            });

    public Map<String, AssayType> getAssayTypes(@NotNull Container container)
    {
        return _assayTypesCache.get(getAssayTypesCacheKey(container), container);
    }

    private String getAssayTypesCacheKey(@NotNull Container container)
    {
        return "AdjAssayTypes:" + container.getId();
    }

    public boolean hasAssayTypes(@NotNull Container container)
    {
        return getAssayTypes(container).size() > 0;
    }

    public void clearAssayTypesCache(@NotNull Container container)
    {
        _assayTypesCache.remove(getAssayTypesCacheKey(container));
    }

    @Nullable
    public Integer getAssayTypeId(@NotNull Container container, String assayTypeName)
    {
        if (null != assayTypeName)
        {
            Map<String, AssayType> assayTypes = getAssayTypes(container);
            AssayType assayType = assayTypes.get(StringUtils.replacePattern(assayTypeName, "\\s", ""));
            if (null == assayType)
            {
                // Check EIA special cases
                if (StringUtils.startsWith(assayTypeName.toLowerCase(), "eia"))
                    assayType = assayTypes.get("eia");
            }

            if (null != assayType)
                return assayType.getRowId();
        }
        return null;
    }

    public void setDefaultSupportedKits(final Container container, final User user) throws Exception
    {
        Container rootContainer = ContainerManager.getRoot();
        if (rootContainer.equals(container))
        {
            _log.warning("Cannot set supported kit defaults on root container");
            return;
        }

        final TableInfo tableInfo = AdjudicationSchema.getInstance().getTableInfoSupportedKits();
        try (DbScope.Transaction transaction = tableInfo.getSchema().getScope().ensureTransaction())
        {
            new TableSelector(AdjudicationSchema.getInstance().getTableInfoKit())
                    .forEachMap(row ->
                    {
                        Map<String, Object> supportedKitRow = new HashMap<>();
                        supportedKitRow.put("KitCode", row.get("Code"));
                        supportedKitRow.put("Container", container.getEntityId());
                        Table.insert(user, tableInfo, supportedKitRow);
                    });
            transaction.commit();
        }
    }

    public boolean hasSupportedKits(@NotNull Container container)
    {
        return new TableSelector(AdjudicationSchema.getInstance().getTableInfoSupportedKits(), SimpleFilter.createContainerFilter(container), null).exists();
    }
}
