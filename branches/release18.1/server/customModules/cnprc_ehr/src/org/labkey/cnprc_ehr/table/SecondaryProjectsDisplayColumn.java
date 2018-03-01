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
package org.labkey.cnprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.util.PageFlowUtil;
import org.springframework.util.StringUtils;

public class SecondaryProjectsDisplayColumn extends DataColumn
{
    public SecondaryProjectsDisplayColumn(ColumnInfo col)
    {
        super(col);
    }

    @Override
    public String getFormattedValue(RenderContext ctx)
    {
        String secondaryProject = (String)ctx.get(getColumnInfo().getFieldKey());
        StringBuilder html = new StringBuilder();
        if ( secondaryProject != null && !secondaryProject.isEmpty())
        {
            String[] projectIds = secondaryProject.split(",");
            String[] secProjectIds = StringUtils.removeDuplicateStrings(projectIds);

            for (int i = 0; i < secProjectIds.length; i++)
            {
                String projectId = PageFlowUtil.filter(secProjectIds[i]);
                if (i > 0)
                {
                    html.append(", ");
                }
                html.append("<a href=\"cnprc_ehr-projectDetails.view?project=" + projectId + "\">" + projectId +"</a>");
            }
        }
        else
        {
            html.append("&nbsp;");
        }

        return html.toString();
    }
}
