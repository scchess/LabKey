/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
package org.labkey.illumina;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExperimentUrls;
import org.labkey.api.exp.query.ExpRunTable;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.security.User;
import org.labkey.api.study.assay.AssayProtocolSchema;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ActionURL;

import java.util.Collections;

/**
 * User: jeckels
 * Date: 10/19/12
 */
public class IlluminaProtocolSchema extends AssayProtocolSchema
{
    public IlluminaProtocolSchema(User user, Container container, @NotNull IlluminaAssayProvider provider, @NotNull ExpProtocol protocol, @Nullable Container targetStudy)
    {
        super(user, container, provider, protocol, targetStudy);
    }

    @Override
    public ExpRunTable createRunsTable()
    {
        // We want to go to the experiment details page instead of the results grid view
        ExpRunTable result = super.createRunsTable();

        // There's no public API for creating this DetailsURL, so get a link to a specific (bogus) run and drop the parameters
        ActionURL url = PageFlowUtil.urlProvider(ExperimentUrls.class).getRunTextURL(getContainer(), -1);
        url.deleteParameters();
        result.setDetailsURL(new DetailsURL(url, Collections.singletonMap("rowId", "RowId")));

        return result;
    }


    @Override
    public FilteredTable createDataTable(boolean includeCopiedToStudyColumns)
    {
        return null;
    }
}
