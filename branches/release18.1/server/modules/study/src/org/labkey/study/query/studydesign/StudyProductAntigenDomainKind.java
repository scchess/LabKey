/*
 * Copyright (c) 2013 LabKey Corporation
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
package org.labkey.study.query.studydesign;

import org.labkey.api.data.JdbcType;
import org.labkey.api.data.PropertyStorageSpec;
import org.labkey.study.query.StudyQuerySchema;

import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Created by klum on 12/13/13.
 */
public class StudyProductAntigenDomainKind extends AbstractStudyDesignDomainKind
{
    public static final String NAME = "StudyProductAntigenDomain";
    public static String NAMESPACE_PREFIX = "StudyDesign-" + NAME;
    private static final Set<PropertyStorageSpec> _baseFields;

    static {
        Set<PropertyStorageSpec> baseFields = new LinkedHashSet<>();
        baseFields.add(createFieldSpec("RowId", JdbcType.INTEGER, true, true));
        baseFields.add(createFieldSpec("ProductId", JdbcType.INTEGER).setNullable(false));
        baseFields.add(createFieldSpec("Gene", JdbcType.VARCHAR).setSize(200));
        baseFields.add(createFieldSpec("SubType", JdbcType.VARCHAR).setSize(200));
        baseFields.add(createFieldSpec("GenBankId", JdbcType.VARCHAR).setSize(200));
        baseFields.add(createFieldSpec("Sequence", JdbcType.VARCHAR).setSize(200));

        _baseFields = Collections.unmodifiableSet(baseFields);
    }

    public StudyProductAntigenDomainKind()
    {
        super(StudyQuerySchema.PRODUCT_ANTIGEN_TABLE_NAME, _baseFields);
    }

    @Override
    protected String getNamespacePrefix()
    {
        return NAMESPACE_PREFIX;
    }

    @Override
    public String getKindName()
    {
        return NAME;
    }
}
