/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

import org.apache.log4j.Logger;
import org.labkey.adjudication.security.AdjudicationCaseUploadPermission;
import org.labkey.adjudication.security.AdjudicationPermission;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.DeferredUpgrade;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.PropertyStorageSpec;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.data.UpgradeCode;
import org.labkey.api.data.dialect.SqlDialect;
import org.labkey.api.exp.ChangePropertyDescriptorException;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.exp.property.DomainKind;
import org.labkey.api.exp.property.PropertyService;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.User;
import org.springframework.validation.BindException;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.labkey.adjudication.AdjudicationSchema.PROVISIONED_STORAGE_SCHEMA_NAME;
import static org.labkey.adjudication.AdjudicationUserSchema.ASSAY_RESULTS_TABLE_NAME;

/**
 * Created by davebradlee on 11/23/15
 */

public class AdjudicationUpgradeCode implements UpgradeCode
{
    private static final Logger _log = Logger.getLogger(AdjudicationUpgradeCode.class);

    /**
     * Invoked from 15.30-16.10
     */
    @SuppressWarnings({"UnusedDeclaration"})
    @DeferredUpgrade
    public void populateAdjudicationUserAndUpdateDetermination(final ModuleContext context)
    {
        if (context.isNewInstall())
            return;

        try (DbScope.Transaction transaction = AdjudicationSchema.getInstance().getSchema().getScope().ensureTransaction())
        {
            TableInfo adjUserTable = AdjudicationSchema.getInstance().getTableInfoAdjudicationUser();
            TableInfo detTable = AdjudicationSchema.getInstance().getTableInfoDetermination();
            for (Container c : ContainerManager.getAllChildren(ContainerManager.getRoot()))
            {
                if (c.getActiveModules().contains(ModuleLoader.getInstance().getModule(AdjudicationModule.class)))
                {
                    Map<String, Object> row = new HashMap<>();
                    row.put("Container", c.getId());
                    int slot = 1;
                    for (User user : SecurityManager.getUsersWithPermissions(c, Collections.singleton(AdjudicationPermission.class)))
                    {
                        if (slot > 2)
                        {
                            _log.warn("More than 2 adjudicators; ignoring " + user.getDisplayName(context.getUpgradeUser()));
                            break;
                        }
                        row.put(AdjudicationUserTable.USERID, user.getUserId());
                        row.put(AdjudicationUserTable.ROLEID, AdjudicationUserTable.getAdjudicationRole(AdjudicationUserTable.ADJUDICATOR));
                        row.put("Slot", slot);
                        Table.insert(context.getUpgradeUser(), adjUserTable, row);
                        slot++;
                    }

                    for (User user : SecurityManager.getUsersWithPermissions(c, Collections.singleton(AdjudicationCaseUploadPermission.class)))
                    {
                        row.put(AdjudicationUserTable.USERID, user.getUserId());
                        row.put(AdjudicationUserTable.ROLEID, AdjudicationUserTable.getAdjudicationRole(AdjudicationUserTable.LABPERSONNEL));
                        row.put("Slot", null);
                        Table.insert(context.getUpgradeUser(), adjUserTable, row);
                    }

                    if ("Adjudication".equalsIgnoreCase(c.getFolderType().getName()))
                    {
                        BindException errors = new BindException(new Object(), "dummy");
                        ContainerManager.refreshFolderType(c, context.getUpgradeUser(), errors);
                        if (errors.hasErrors())
                            _log.warn("Refresh folder type error: " + errors.getMessage());
                    }
                }
            }
            // Update script to change in Determination table each adjudicationUserId to slot
            SQLFragment sql = new SQLFragment("UPDATE ");
            String detTableSelectName = detTable.getSelectName();
            sql.append(detTableSelectName).append(" SET Slot = (SELECT Slot FROM ")
                    .append(adjUserTable.getFromSQL("u"))
                    .append(" WHERE u.UserId = ").append(detTableSelectName).append(".Slot AND u.Container = ")
                    .append(detTableSelectName).append(".Container").append(")");
            new SqlExecutor(detTable.getSchema()).execute(sql);
            transaction.commit();
        }
    }

    /**
     * Invoked from 16.31-16.32 to add a new domain field : PostComplete
     */
    @SuppressWarnings({"UnusedDeclaration"})
    public void updateAssayResultsTable(final ModuleContext context)
    {
        if (!context.isNewInstall())
        {
            try (DbScope.Transaction transaction = AdjudicationSchema.getInstance().getSchema().getScope().ensureTransaction())
            {
                DomainKind domainKind = new AssayResultsDomainKind();
                SqlDialect dialect = AdjudicationSchema.getInstance().getSqlDialect();

                for (Container c : ContainerManager.getAllChildren(ContainerManager.getRoot()))
                {
                    String domainURI = domainKind.generateDomainURI(PROVISIONED_STORAGE_SCHEMA_NAME, ASSAY_RESULTS_TABLE_NAME, c, context.getUpgradeUser());
                    Domain domain = PropertyService.get().getDomain(c, domainURI);

                    if (domain != null)
                    {
                        _log.info("Adding the PostComplete field to the AssayResults table in folder : " + c.getPath());
                        String queryName = domain.getStorageTableName();
                        SQLFragment sql = new SQLFragment("ALTER TABLE ").append(PROVISIONED_STORAGE_SCHEMA_NAME).append(".").append(queryName);

                        if (dialect.isPostgreSQL())
                            sql.append(" ADD COLUMN PostComplete BOOLEAN NOT NULL DEFAULT FALSE");
                        else if (dialect.isSqlServer())
                            sql.append(" ADD PostComplete BIT NOT NULL DEFAULT 0");

                        new SqlExecutor(AdjudicationSchema.getInstance().getSchema()).execute(sql);
                    }
                }
                transaction.commit();
            }
        }
    }

    /**
     * Invoked from 17.30-17.31
     */
    @SuppressWarnings({"UnusedDeclaration"})
    @DeferredUpgrade
    public void populateRootDefaultAssayTypes(final ModuleContext context)
    {
        // We do execute this even in the bootstrap case

        final Container rootContainer = ContainerManager.getRoot();
        SQLFragment sql = new SQLFragment("INSERT INTO adjudication.AssayType (Name, Label, Container) VALUES \n")
           .append(" ('geenius', 'Geenius', ?),")
           .append(" ('totalnucleicacid', 'Total Nucleic Acid', ?),")
           .append(" ('eia', 'ELISA', ?),")
           .append(" ('elisa', 'ELISA', ?),")
           .append(" ('rnapcr', 'RNA PCR', ?),")
           .append(" ('dnapcr', 'DNA PCR', ?),")
           .append(" ('multispot', 'MULTISPOT', ?),")
           .append(" ('wb', 'Western Blot', ?),")
           .append(" ('westernblot', 'Western Blot', ?),")
           .append(" ('opendiscretionary', 'Open Discretionary', ?)");
        sql.add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer)
           .add(rootContainer);

        new SqlExecutor(AdjudicationSchema.getInstance().getSchema()).execute(sql);

        if (!context.isNewInstall())
        {
            // Update existing adjudication folders
            final DbSchema expSchema = DbSchema.get("exp", DbSchemaType.Module);
            final User user = context.getUpgradeUser();
            final SqlDialect dialect = AdjudicationSchema.getInstance().getSqlDialect();

            ContainerManager.getAllChildrenWithModule(rootContainer, ModuleLoader.getInstance().getModule(context.getName()))
                .forEach(container ->
                {
                    if (!rootContainer.equals(container))
                    {
                        try
                        {
                            AdjudicationManager.get().setDefaultAssayTypes(container, user);
                        }
                        catch (Exception e)
                        {
                            _log.error("Unable to set assay type defaults in folder '" + container.getPath() + "': " + e.getMessage());
                        }
                    }
                });

        }
    }
}
