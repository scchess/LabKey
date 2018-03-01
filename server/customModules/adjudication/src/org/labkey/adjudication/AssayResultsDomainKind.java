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

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.PropertyStorageSpec;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SchemaTableInfo;
import org.labkey.api.exp.Lsid;
import org.labkey.api.exp.api.ExperimentUrls;
import org.labkey.api.exp.property.AbstractDomainKind;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.api.writer.ContainerUser;
import org.labkey.data.xml.TableType;

import java.text.ParseException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by davebradlee on 10/1/15.
 *
 */
public class AssayResultsDomainKind extends AbstractDomainKind
{
    private static final String NAME = "AssayResults";
    private static final String NAMESPACE_PREFIX = "AssayResults";

    public AssayResultsDomainKind()
    {
        super();
    }

    public String getTypeLabel(Domain domain)
    {
        return domain.getName();
    }
    public String getKindName()
    {
        return NAME;
    }
    protected String getNamespacePrefix()
    {
        return NAMESPACE_PREFIX;
    }

    @NotNull
    public ActionURL urlEditDefinition(Domain domain, ContainerUser containerUser)
    {
        ExperimentUrls provider = PageFlowUtil.urlProvider(ExperimentUrls.class);
        if (null == provider)
            throw new IllegalStateException("ExperimentUrls not found.");
        return provider.getDomainEditorURL(containerUser.getContainer(), domain.getTypeURI(), false, false, false);
    }

    public ActionURL urlShowData(Domain domain, ContainerUser containerUser)
    {
        return null;
    }

    @Override
    public Priority getPriority(String domainURI)
    {
        Lsid lsid = new Lsid(domainURI);
        return lsid.getNamespacePrefix() != null && getNamespacePrefix().equals(lsid.getNamespacePrefix()) ? Priority.MEDIUM : null;
    }

    public Set<String> getReservedPropertyNames(Domain domain)
    {
        return new HashSet<>();
    }

    @Override
    public DbScope getScope()
    {
        return AdjudicationSchema.getInstance().getSchema().getScope();
    }

    @Override
    public String getStorageSchemaName()
    {
        return AdjudicationSchema.PROVISIONED_STORAGE_SCHEMA_NAME;
    }

    @Override
    public DbSchemaType getSchemaType()
    {
        return DbSchemaType.Provisioned;
    }

    @Override
    public String getMetaDataSchemaName()
    {
        return "adjudication";
    }

    @Override
    public String getMetaDataTableName()
    {
        return getKindName();
    }

    @Override
    public String generateDomainURI(String schemaName, String queryName, Container container, User user)
    {
        Lsid lsid = new Lsid(getNamespacePrefix(), container.getId(), schemaName.toLowerCase() + "-" + queryName.toLowerCase());
        return lsid.toString();
    }

    @Override
    public SQLFragment sqlObjectIdsInDomain(Domain domain)
    {
        return new SQLFragment("NULL");
    }

    @Override
    public void afterLoadTable(SchemaTableInfo ti, Domain domain)
    {
        // Grab the meta data for this table (event, vial, or specimen) and apply it to the provisioned table
        DbSchema schema = AdjudicationSchema.getInstance().getSchema();
        TableType xmlTable = schema.getTableXmlMap().get(getMetaDataTableName());
        ti.loadTablePropertiesFromXml(xmlTable, true);
    }

    public static final String ROWID = "RowId";
    public static final String PARTICIPANTID = "ParticipantId";
    public static final String ENTITYID = "EntityId";
    public static final String VISIT = "Visit";
    public static final String NETWORK = "Network";
    public static final String LAB = "Lab";
    public static final String ASSAYTYPE = "AssayType";
    public static final String ASSAYKIT = "AssayKit";
    public static final String RESULT = "Result";
    public static final String DRAWDATE = "DrawDate";
    public static final String COPIESML = "CopiesML";
    public static final String TESTDATE = "TestDate";
    public static final String CTRLBAND = "CTRLBand";
    public static final String HIV1INTERPRETATION = "HIV-1Interpretation";
    public static final String HIV2INTERPRETATION = "HIV-2Interpretation";
    public static final String COMMENT = "Comment";
    public static final String CASEID = "CaseId";
    public static final String POSTCOMPLETE = "PostComplete";

    static
    {
        PropertyStorageSpec[] props =
        {
            new PropertyStorageSpec(ROWID, JdbcType.INTEGER, 0, PropertyStorageSpec.Special.PrimaryKey, false, true, null),
            new PropertyStorageSpec(PARTICIPANTID, JdbcType.VARCHAR, 32),
            new PropertyStorageSpec(ENTITYID, JdbcType.GUID),
            new PropertyStorageSpec(VISIT, JdbcType.DOUBLE, 0),
            new PropertyStorageSpec(NETWORK, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(LAB, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(ASSAYTYPE, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(ASSAYKIT, JdbcType.VARCHAR, 20),
            new PropertyStorageSpec(RESULT, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(DRAWDATE, JdbcType.DATE, 0),
            new PropertyStorageSpec(COPIESML, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(TESTDATE, JdbcType.DATE, 0),
            new PropertyStorageSpec(COMMENT, JdbcType.VARCHAR, 500),
            new PropertyStorageSpec(CASEID, JdbcType.INTEGER, 0),
            new PropertyStorageSpec(POSTCOMPLETE, JdbcType.BOOLEAN, 0, false, Boolean.FALSE),
        };
        BASE_PROPERTIES = Arrays.asList(props);
    }

    private static final List<PropertyStorageSpec> BASE_PROPERTIES;

    @Override
    public Set<PropertyStorageSpec> getBaseProperties(Domain domain)
    {
        return new LinkedHashSet<>(BASE_PROPERTIES);
    }

    public Set<PropertyStorageSpec> getPropertySpecsFromTemplate(AssayResultsTemplate template)
    {
        return template.getExtraProperties();
    }

    public Set<PropertyStorageSpec.ForeignKey> getPropertyForeignKeys()
    {
        return Collections.singleton(new PropertyStorageSpec.ForeignKey(ASSAYKIT, "adjudication", "Kit", "Code", null, false));
    }

    @Override
    public Set<String> getNonProvisionedTableNames()
    {
        return Collections.emptySet();
    }

    public static String translateColumnName(String key)
    {
        if ("ASSAYTYP".equalsIgnoreCase(key))
            key = ASSAYTYPE;
        else if ("COPIES_ML".equalsIgnoreCase(key))
            key = COPIESML;
        else if ("PTID".equalsIgnoreCase(key))
            key = PARTICIPANTID;
        else if ("DRAWDT".equalsIgnoreCase(key))
            key = DRAWDATE;
        else if ("TESTDT".equalsIgnoreCase(key))
            key = TESTDATE;
        else if ("CTRL_Band".equalsIgnoreCase(key))
            key = CTRLBAND;
        else if ("HIV-1 Interpretation".equalsIgnoreCase(key))
            key = HIV1INTERPRETATION;
        else if ("HIV-2 Interpretation".equalsIgnoreCase(key))
            key = HIV2INTERPRETATION;
        return key;
    }

    public static String reverseTranslateColumnName(String key)
    {
        if (ASSAYTYPE.equalsIgnoreCase(key))
            key = "ASSAYTYP";
        else if (COPIESML.equalsIgnoreCase(key))
            key = "COPIES_ML";
        else if (PARTICIPANTID.equalsIgnoreCase(key))
            key = "PTID";
        else if (DRAWDATE.equalsIgnoreCase(key))
            key = "DRAWDT";
        else if (TESTDATE.equalsIgnoreCase(key))
            key = "TESTDT";
        else if (CTRLBAND.equalsIgnoreCase(key))
            key = "CTRL_Band";
        else if (HIV1INTERPRETATION.equalsIgnoreCase(key))
            key = "HIV-1 Interpretation";
        else if (HIV2INTERPRETATION.equalsIgnoreCase(key))
            key = "HIV-2 Interpretation";
        return key;
    }

    public static Object translateDate(String key, Object value) throws ParseException
    {
        if ((DRAWDATE.equalsIgnoreCase(key) || TESTDATE.equalsIgnoreCase(key)) && !(value instanceof Date))
            return DateUtil.parseDateTime(value.toString(), DateUtil.getJsonDateTimeFormatString());

        return value;
    }
}
