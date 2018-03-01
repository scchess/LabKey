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

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.labkey.adjudication.security.AdjudicationCaseUploadPermission;
import org.labkey.adjudication.security.AdjudicationDataReviewerRole;
import org.labkey.adjudication.security.AdjudicationInfectionMonitorRole;
import org.labkey.adjudication.security.AdjudicationLabPersonnelRole;
import org.labkey.adjudication.security.AdjudicationPermissionsTest;
import org.labkey.adjudication.security.AdjudicatorRole;
import org.labkey.api.action.SimpleErrorView;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.admin.notification.Notification;
import org.labkey.api.admin.notification.NotificationService;
import org.labkey.api.attachments.AttachmentService;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.UpgradeCode;
import org.labkey.api.exp.property.PropertyService;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.module.ModuleProperty;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QuerySettings;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.util.SystemMaintenance;
import org.labkey.api.view.BaseWebPartFactory;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.JspView;
import org.labkey.api.view.Portal;
import org.labkey.api.view.VBox;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.WebPartView;
import org.springframework.validation.BindException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.labkey.adjudication.AdjudicationUserSchema.ASSAY_TYPES_TABLE_NAME;
import static org.labkey.adjudication.AdjudicationUserSchema.SUPPORTED_KITS_TABLE_NAME;

/**
 * Created by davebradlee on 9/28/15.
 *
 */
public class AdjudicationModule extends DefaultModule
{
    public static final String NAME = "adjudication";
    public static final String PROTOCOL_NAME_PROPERTY = "ProtocolName";
    public static final String AUTOMATIC_REMINDERS_PROPERTY = "AutomaticReminders";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public double getVersion()
    {
        return 18.10;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @NotNull
    @Override
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        List<WebPartFactory> webPartFactories = new ArrayList<>();
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Admin Dashboard")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    JspView view = new JspView("/org/labkey/adjudication/view/adminDashboard.jsp");
                    view.setTitle("Dashboard");
                    return view;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Dashboard")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    JspView view = new JspView("/org/labkey/adjudication/view/adjudicationDashboard.jsp");
                    view.setTitle("Dashboard");
                    return view;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Alerts")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    Container c = portalCtx.getContainer();
                    User u = portalCtx.getUser();
                    List<Notification> allNotifications = NotificationService.get().getNotificationsByUser(c, u.getUserId(), true);
                    if (allNotifications.size() > 0)
                    {
                        JspView view = new JspView("/org/labkey/adjudication/view/notifications.jsp");
                        view.setTitle("Notifications");
                        return view;
                    }
                    else
                    {
                        return null;
                    }
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Case Summary Report", WebPartFactory.LOCATION_RIGHT)
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    JspView view = new JspView("/org/labkey/adjudication/view/caseSummaryReport.jsp");
                    view.setTitle("Case Summary Report");
                    return view;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Upload Wizard")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    boolean hasCaseUpload = portalCtx.hasPermission(AdjudicationCaseUploadPermission.class);
                    boolean hasAdmin = portalCtx.hasPermission(AdminPermission.class);

                    if (hasAdmin || !hasCaseUpload)
                        return new HtmlView("Upload Wizard", "<div class=\"labkey-error\">You do not have permission to view this wizard.</div>");

                    AdjudicationManager manager = AdjudicationManager.get();
                    String filenamePrefix = manager.getFilenamePrefix(portalCtx.getContainer());

                    if (null != filenamePrefix)
                    {
                        UploadWizardForm form = new UploadWizardForm();
                        form.setFilenamePrefix(filenamePrefix);
                        form.setAllowedFields(new JSONArray(manager.getAllowedAssayResultFields(portalCtx.getContainer())));
                        JspView view = new JspView<>("/org/labkey/adjudication/view/uploadWizard.jsp", form);
                        view.setTitle("Upload Wizard");
                        return view;
                    }
                    else
                    {
                        BindException errors = new BindException(new Object(), "dummy");
                        errors.reject(SpringActionController.ERROR_MSG, "Filename prefix is not set properly. Please contact an administrator.");
                        return new SimpleErrorView(errors, false);
                    }
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Welcome")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    JspView view = new JspView("/org/labkey/adjudication/view/adjudicationWelcome.jsp");
                    view.setTitle("Adjudication Committee");
                    return view;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Manage")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    if (portalCtx.getContainer().hasPermission(portalCtx.getUser(), AdminPermission.class))
                    {
                        AdjudicationController.ManageSettingsForm form = AdjudicationManager.get().getManageSettingsProperties(portalCtx.getContainer());
                        JspView view = new JspView<>("/org/labkey/adjudication/view/manageAdjudication.jsp", form);
                        view.setTitle("Manage Adjudication");
                        return view;
                    }
                    return null;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Users")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    if (portalCtx.getContainer().hasPermission(portalCtx.getUser(), AdminPermission.class))
                    {
                        UserSchema schema = QueryService.get().getUserSchema(portalCtx.getUser(), portalCtx.getContainer(), "adjudication");
                        if (null == schema)
                            return new HtmlView("Adjudication Users", "Schema 'adjudication' could not be found.");

                        QuerySettings settings = new QuerySettings(portalCtx, "adjuser", "AdjudicationUser");
                        QueryView userView = new QueryView(schema, settings, null);
                        userView.setTitle("Adjudication Users");

                        AdjudicationController.ManageSettingsForm form = AdjudicationManager.get().getManageSettingsProperties(portalCtx.getContainer());
                        JspView teamView = new JspView<>("/org/labkey/adjudication/view/teamAssignment.jsp", form);
                        teamView.setTitle("Adjudicator Team Members");

                        VBox vBox = new VBox(userView);
                        vBox.addView(teamView);
                        return vBox;
                    }
                    return null;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Assay Kits")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    if (portalCtx.getContainer().hasPermission(portalCtx.getUser(), AdminPermission.class))
                    {
                        UserSchema schema = QueryService.get().getUserSchema(portalCtx.getUser(), portalCtx.getContainer(), "adjudication");
                        if (null == schema)
                            return new HtmlView("Supported Assay Kits", "Schema 'adjudication' could not be found.");

                        BindException errors = new BindException(new Object(), "dummy");
                        QuerySettings settings = new QuerySettings(portalCtx, "adjkit", SUPPORTED_KITS_TABLE_NAME);
                        QueryView view = schema.createView(portalCtx, settings, errors);
                        view.setTitle("Supported Assay Kits");
                        return view;
                    }
                    return null;
                }
            }
        );
        webPartFactories.add(
            new BaseWebPartFactory("Adjudication Assay Types")
            {
                @Override
                public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
                {
                    if (portalCtx.getContainer().hasPermission(portalCtx.getUser(), AdminPermission.class))
                    {
                        UserSchema schema = QueryService.get().getUserSchema(portalCtx.getUser(), portalCtx.getContainer(), "adjudication");
                        if (null == schema)
                            return new HtmlView("Assay Types", "Schema 'adjudication' could not be found.");

                        BindException errors = new BindException(new Object(), "dummy");
                        QuerySettings settings = new QuerySettings(portalCtx, "adjassaytype", ASSAY_TYPES_TABLE_NAME);
                        QueryView view = schema.createView(portalCtx, settings, errors);
                        view.setTitle("Assay Types");
                        return view;
                    }
                    return null;
                }
            }
        );

        return webPartFactories;
    }

    public static class UploadWizardForm
    {
        private String _filenamePrefix;
        private JSONArray _allowedFields;

        public String getFilenamePrefix()
        {
            return _filenamePrefix;
        }

        public void setFilenamePrefix(String filenamePrefix)
        {
            _filenamePrefix = filenamePrefix;
        }

        public JSONArray getAllowedFields()
        {
            return _allowedFields;
        }

        public void setAllowedFields(JSONArray allowedFields)
        {
            _allowedFields = allowedFields;
        }
    }

    @Override
    protected void init()
    {
        addController("adjudication", AdjudicationController.class);

        // Note: Permissions associated with these roles are not granted to administrators automatically
        RoleManager.registerRole(new AdjudicatorRole(), false);
        RoleManager.registerRole(new AdjudicationLabPersonnelRole(), false);
        RoleManager.registerRole(new AdjudicationInfectionMonitorRole(), false);
        RoleManager.registerRole(new AdjudicationDataReviewerRole(), false);

        NotificationService.get().registerNotificationType(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseCreated.name(), "Adjudication", null);
        NotificationService.get().registerNotificationType(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseAssayDataUpdated.name(), "Adjudication", null);
        NotificationService.get().registerNotificationType(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseCompleted.name(), "Adjudication", null);
        NotificationService.get().registerNotificationType(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseDeterminationUpdated.name(), "Adjudication", null);
        NotificationService.get().registerNotificationType(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseReadyForVerification.name(), "Adjudication", null);
        NotificationService.get().registerNotificationType(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseResolutionRequired.name(), "Adjudication", null);
    }

    @Override
    public void doStartup(ModuleContext moduleContext)
    {
        DefaultSchema.registerProvider(AdjudicationSchema.SCHEMA_NAME, new DefaultSchema.SchemaProvider(this)
        {
            public QuerySchema createSchema(final DefaultSchema schema, Module module)
            {
                return new AdjudicationUserSchema(AdjudicationSchema.SCHEMA_NAME, null, schema.getUser(), schema.getContainer(), AdjudicationSchema.getInstance().getSchema());
            }
        });

        PropertyService.get().registerDomainKind(new AssayResultsDomainKind());
        ContainerManager.addContainerListener(new AdjudicationContainerListener());

        ModuleProperty protocolNameProperty = new ModuleProperty(this, PROTOCOL_NAME_PROPERTY);
        protocolNameProperty.setLabel("Protocol/Study Name");
        protocolNameProperty.setDescription("The protocol/study display name to be used as an email subject/header prefix and case results page header prefix.");
        protocolNameProperty.setCanSetPerContainer(true);
        protocolNameProperty.setShowDescriptionInline(true);
        addModuleProperty(protocolNameProperty);

        ModuleProperty automaticRemindersProperty = new ModuleProperty(this, AUTOMATIC_REMINDERS_PROPERTY);
        automaticRemindersProperty.setLabel("Automatic Reminders");
        automaticRemindersProperty.setDescription("Send daily email reminders to adjudicators of cases that are open.");
        automaticRemindersProperty.setInputType(ModuleProperty.InputType.checkbox);
        automaticRemindersProperty.setDefaultValue("FALSE");
        automaticRemindersProperty.setCanSetPerContainer(true);
        automaticRemindersProperty.setShowDescriptionInline(true);
        addModuleProperty(automaticRemindersProperty);

        //add the email reminder to adjudicators task to the list of system maintenance tasks
        SystemMaintenance.addTask(new AdjudicatorEmailReminderTask());

        AttachmentService.get().registerAttachmentType(AdjudicationAssayResultType.get());
    }

    @NotNull
    @Override
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        Set<String> schemaNames = new HashSet<>();
        schemaNames.add(AdjudicationSchema.SCHEMA_NAME);
        schemaNames.addAll(getProvisionedSchemaNames());
        return schemaNames;
    }

    @Override
    @NotNull
    public Set<String> getProvisionedSchemaNames()
    {
        return Collections.singleton(AdjudicationSchema.PROVISIONED_STORAGE_SCHEMA_NAME);
    }

    @Override
    public UpgradeCode getUpgradeCode()
    {
        return new AdjudicationUpgradeCode();
    }

    @NotNull
    @Override
    public Set<Class> getUnitTests()
    {
        return new HashSet<>(Arrays.asList(
                AdjudicationTeamUserQueryUpdateService.AdjudicationTeamUserQueryUpdateServiceTest.class
        ));
    }

    @NotNull
    @Override
    public Set<Class> getIntegrationTests()
    {
        return Collections.singleton(AdjudicationPermissionsTest.class);
    }
}
