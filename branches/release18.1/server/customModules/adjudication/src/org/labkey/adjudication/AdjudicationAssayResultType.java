/*
 * Copyright (c) 2017 LabKey Corporation
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

import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.attachments.AttachmentType;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.exp.property.Domain;

import java.util.LinkedList;
import java.util.List;

public class AdjudicationAssayResultType implements AttachmentType
{
    private static final AdjudicationAssayResultType INSTANCE = new AdjudicationAssayResultType();

    public static AdjudicationAssayResultType get()
    {
        return INSTANCE;
    }

    private AdjudicationAssayResultType()
    {
    }

    @Override
    public @NotNull String getUniqueName()
    {
        return getClass().getName();
    }

    @Override
    public void addWhereSql(SQLFragment sql, String parentColumn, String documentNameColumn)
    {
        AdjudicationSchema schema = AdjudicationSchema.getInstance();
        List<String> statements = new LinkedList<>();

        ContainerManager.getAllChildren(ContainerManager.getRoot()).forEach(c -> {
            Domain domain = schema.getAssayResultsDomainIfExists(c, null);

            if (null != domain)
            {
                TableInfo tinfo = schema.getTableInfoAssayResults(c, null);
                statements.add("\n    SELECT EntityId AS ID FROM " + tinfo.getSelectName());
            }
        });

        if (statements.isEmpty())
            sql.append("1 = 0");  //  No adjudication assay results
        else
            sql.append(parentColumn).append(" IN (").append(StringUtils.join(statements, "\n    UNION")).append(")");
    }
}
