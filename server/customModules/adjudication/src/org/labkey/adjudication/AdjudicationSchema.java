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
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.PropertyStorageSpec;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.dialect.SqlDialect;
import org.labkey.api.exp.ChangePropertyDescriptorException;
import org.labkey.api.exp.DomainNotFoundException;
import org.labkey.api.exp.api.StorageProvisioner;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.exp.property.DomainProperty;
import org.labkey.api.exp.property.PropertyService;
import org.labkey.api.security.User;

import static org.labkey.adjudication.AdjudicationUserSchema.ASSAY_RESULTS_TABLE_NAME;

/**
 * Created by davebradlee on 9/28/15.
 *
 */
public class AdjudicationSchema
{
    private static final AdjudicationSchema _instance = new AdjudicationSchema();
    private final AssayResultsDomainKind _assayResultsDomainKind = new AssayResultsDomainKind();
    private final AssayResultsTemplate _template = new DefaultAssayResultsTemplate();   // If we ever allow more templates, tease out into a provider

    public static final String SCHEMA_NAME = "adjudication";
    public static final String PROVISIONED_STORAGE_SCHEMA_NAME = "adjudicationtables";

    public static AdjudicationSchema getInstance()
    {
        return _instance;
    }

    private AdjudicationSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.adjudication.security.AdjudicationSchema.getInstance()
    }

    public DbSchema getSchema()
    {
        return DbSchema.get("adjudication", DbSchemaType.Module);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }


    public TableInfo getTableInfoKit()
    {
        return getSchema().getTable("Kit");
    }
    public TableInfo getTableInfoStatus()
    {
        return getSchema().getTable("Status");
    }
    public TableInfo getTableInfoAdjudicationCase()
    {
        return getSchema().getTable("AdjudicationCase");
    }
    public TableInfo getTableInfoDetermination()
    {
        return getSchema().getTable("Determination");
    }
    public TableInfo getTableInfoVisit()
    {
        return getSchema().getTable("Visit");
    }
    public TableInfo getTableInfoAdjudicationUser()
    {
        return getSchema().getTable("AdjudicationUser");
    }
    public TableInfo getTableInfoAdjudicationTeamUser()
    {
        return getSchema().getTable("AdjudicationTeamUser");
    }
    public TableInfo getTableInfoSupportedKits()
    {
        return getSchema().getTable("SupportedKits");
    }
    public TableInfo getTableInfoCaseDocuments()
    {
        return getSchema().getTable("CaseDocuments");
    }
    public TableInfo getTableInfoAssayType()
    {
        return getSchema().getTable("AssayType");
    }

    @NotNull
    public TableInfo getTableInfoAssayResults(Container container, User user)
    {
        return StorageProvisioner.createTableInfo(ensureAssayResultsDomain(container, user));
    }

    @NotNull
    public Domain ensureAssayResultsDomain(Container container, User user)
    {
        Domain domain = getAssayResultsDomainIfExists(container, user);

        if (null == domain)
        {
            // it's possible that another thread is attempting to create the table, so we can (rarely) get a constraint violation
            // We can't try again, but tell the user to try the operation again
            try
            {
                String domainURI = getAssayResultsDomainURI(container, user);
                domain = PropertyService.get().createDomain(container, domainURI, _assayResultsDomainKind.getKindName());

                // Add properties for all required fields
                for (PropertyStorageSpec propSpec : _assayResultsDomainKind.getBaseProperties(domain))
                {
                    DomainProperty prop = domain.addProperty(propSpec);
                    prop.setRequired(true);
                }
                if (null != _template)
                {
                    // Add optional fields to table
                    for (PropertyStorageSpec propSpec : _assayResultsDomainKind.getPropertySpecsFromTemplate(_template))
                    {
                        domain.addProperty(propSpec);
                    }
                }
                domain.setPropertyForeignKeys(_assayResultsDomainKind.getPropertyForeignKeys());
                domain.save(user);
            }
            catch (ChangePropertyDescriptorException e)
            {
                throw new RuntimeException(e);
            }
            catch (RuntimeSQLException e)
            {
                throw new RuntimeException("Cannot create domain for table. Another process may be creating it or may have deleted it. Please try your action again.", e);
            }
        }
        return domain;
    }

    public @Nullable Domain getAssayResultsDomainIfExists(Container container, User user)
    {
        String domainURI = getAssayResultsDomainURI(container, user);

        return PropertyService.get().getDomain(container, domainURI);
    }

    public void deleteAssayResultsTable(Container container, User user)
    {
        try
        {
            String domainURI = getAssayResultsDomainURI(container, user);

            // it's possible that another thread is attempting to create the table, so we can (rarely) get a constraint violation
            // We can't try again, but tell the user to try the operation again
            Domain domain = PropertyService.get().getDomain(container, domainURI);
            if (null != domain)
            {
                domain.delete(user);
            }
        }
        catch (DomainNotFoundException | RuntimeSQLException e)
        {
            // ignore
        }
    }

    @NotNull
    public AssayResultsDomainKind getAssayResultsDomainKind()
    {
        return _assayResultsDomainKind;
    }

    private String getAssayResultsDomainURI(Container container, User user)
    {
        return _assayResultsDomainKind.generateDomainURI(PROVISIONED_STORAGE_SCHEMA_NAME, ASSAY_RESULTS_TABLE_NAME, container, user);
    }
}
