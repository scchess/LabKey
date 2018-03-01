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
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.ActionButton;
import org.labkey.api.data.ButtonBar;
import org.labkey.api.data.Container;
import org.labkey.api.data.CoreSchema;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QuerySettings;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.DataView;
import org.labkey.api.view.UnauthorizedException;
import org.labkey.api.view.ViewContext;
import org.springframework.validation.BindException;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by davebradlee on 10/9/15.
 *
 */
public class AdjudicationUserSchema extends SimpleUserSchema
{
    public static final String ADJ_CASE_TABLE_NAME = "AdjudicationCase";
    public static final String ADJ_TEAM_USER_TABLE_NAME = "AdjudicationTeamUser";
    public static final String ADJ_USER_TABLE_NAME = "AdjudicationUser";
    public static final String ASSAY_ATTACHMENTS_TABLE_NAME = "AssayAttachments";
    public static final String ASSAY_RESULTS_TABLE_NAME = "AssayResults";
    public static final String CASE_DOCUMENTS_TABLE_NAME = "CaseDocuments";
    public static final String DETERMINATION_TABLE_NAME = "Determination";
    public static final String SUPPORTED_KITS_TABLE_NAME = "SupportedKits";
    public static final String VISIT_TABLE = "Visit";
    public static final String ASSAY_TYPES_TABLE_NAME = "AssayTypes";

    public AdjudicationUserSchema(String name, @Nullable String description, User user, Container container, DbSchema dbschema)
    {
        super(name, description, user, container, dbschema);
    }

    @Override
    @Nullable
    public TableInfo createTable(String name)
    {
        if (ASSAY_RESULTS_TABLE_NAME.equalsIgnoreCase(name))
            return new AdjudicationAssayResultsTable(this,
                 AdjudicationSchema.getInstance().getTableInfoAssayResults(getContainer(), getUser()));

        if (ASSAY_ATTACHMENTS_TABLE_NAME.equalsIgnoreCase(name))
        {
            FilteredTable<AdjudicationUserSchema> table = new FilteredTable<>(CoreSchema.getInstance().getTableInfoDocuments(), this);
            table.setName(ASSAY_ATTACHMENTS_TABLE_NAME);
            table.addWrapColumn(table.getRealTable().getColumn("Parent"));
            table.addWrapColumn(table.getRealTable().getColumn("DocumentName"));

            // Only show attachments for this container
            SQLFragment sql = new SQLFragment("(Container = ?)");
            sql.add(getContainer());
            table.addCondition(sql);

            return table;
        }

        if (ADJ_USER_TABLE_NAME.equalsIgnoreCase(name))
            return new AdjudicationUserTable(AdjudicationSchema.getInstance().getTableInfoAdjudicationUser(), this);
        if (ADJ_TEAM_USER_TABLE_NAME.equalsIgnoreCase(name))
            return new AdjudicationTeamUserTable(AdjudicationSchema.getInstance().getTableInfoAdjudicationTeamUser(), this);
        if (SUPPORTED_KITS_TABLE_NAME.equalsIgnoreCase(name))
            return new SupportedKitsTable(AdjudicationSchema.getInstance().getTableInfoSupportedKits(), this);
        if (ADJ_CASE_TABLE_NAME.equalsIgnoreCase(name))
            return new AdjudicationCaseTable(AdjudicationSchema.getInstance().getTableInfoAdjudicationCase(), this);
        if (CASE_DOCUMENTS_TABLE_NAME.equalsIgnoreCase(name))
            return new CaseDocumentsTable(AdjudicationSchema.getInstance().getTableInfoCaseDocuments(), this);
        if (DETERMINATION_TABLE_NAME.equalsIgnoreCase(name))
            return new DefaultAdjudicationTable(AdjudicationSchema.getInstance().getTableInfoDetermination(), this, true, true);
        if (VISIT_TABLE.equalsIgnoreCase(name))
            return new DefaultAdjudicationTable(AdjudicationSchema.getInstance().getTableInfoVisit(), this, true, false);
        if (ASSAY_TYPES_TABLE_NAME.equalsIgnoreCase(name))
            return new AssayTypeTable(AdjudicationSchema.getInstance().getTableInfoAssayType(), this);

        return super.createTable(name);
    }

    @Override
    public Set<String> getVisibleTableNames()
    {
        Set<String> tableNames = new HashSet<>();
        tableNames.add(ADJ_CASE_TABLE_NAME);
        tableNames.add(DETERMINATION_TABLE_NAME);
        tableNames.add("Kit");
        tableNames.add("Status");
        tableNames.add(VISIT_TABLE);
        tableNames.add(ASSAY_RESULTS_TABLE_NAME);
        tableNames.add(ASSAY_ATTACHMENTS_TABLE_NAME);
        tableNames.add(SUPPORTED_KITS_TABLE_NAME);
        tableNames.add(CASE_DOCUMENTS_TABLE_NAME);
        tableNames.add(ASSAY_TYPES_TABLE_NAME);
        return tableNames;
    }

    @Override
    public QueryView createView(ViewContext context, @NotNull QuerySettings settings, BindException errors)
    {
        if (ASSAY_RESULTS_TABLE_NAME.equalsIgnoreCase(settings.getQueryName()))
        {
            QueryView view = new QueryView(this, settings, errors);
            view.setShowUpdateColumn(false);
            return view;
        }
        if (CASE_DOCUMENTS_TABLE_NAME.equalsIgnoreCase(settings.getQueryName()) && !context.getContainer().hasPermission(context.getUser(), AdminPermission.class))
        {
            throw new UnauthorizedException("Only administrators can view the Case Documents Table");
        }
        if (ASSAY_TYPES_TABLE_NAME.equalsIgnoreCase(settings.getQueryName()))
        {
            QueryView view = new QueryView(this, settings, errors)
            {
                @Override
                protected void populateButtonBar(DataView view, ButtonBar bar)
                {
                    super.populateButtonBar(view, bar);
                    if (context.getContainer().hasPermission(context.getUser(), AdminPermission.class) && !AdjudicationManager.get().hasAssayTypes(context.getContainer()))
                        bar.add(createSetDefaultsButton(context, new ActionURL(AdjudicationController.SetDefaultAssayTypesAction.class, getContainer())));
                }
            };
            return view;
        }
        if (SUPPORTED_KITS_TABLE_NAME.equalsIgnoreCase(settings.getQueryName()))
        {
            QueryView view = new QueryView(this, settings, errors)
            {
                @Override
                protected void populateButtonBar(DataView view, ButtonBar bar)
                {
                    super.populateButtonBar(view, bar);
                    if (context.getContainer().hasPermission(context.getUser(), AdminPermission.class) && !AdjudicationManager.get().hasSupportedKits(context.getContainer()))
                        bar.add(createSetDefaultsButton(context, new ActionURL(AdjudicationController.SetDefaultSupportedKitsAction.class, getContainer())));
                }
            };
            view.setShowUpdateColumn(false);
            return view;
        }
        return super.createView(context, settings, errors);
    }

    private ActionButton createSetDefaultsButton(ViewContext context, ActionURL url)
    {
        url.addReturnURL(context.getActionURL());
        ActionButton button = new ActionButton(url, "Set Defaults");
        button.setActionType(ActionButton.Action.POST);
        button.setDisplayPermission(AdminPermission.class);
        return button;
    }

}
