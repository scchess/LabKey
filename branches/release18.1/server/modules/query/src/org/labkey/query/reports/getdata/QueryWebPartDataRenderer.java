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
package org.labkey.query.reports.getdata;

import com.fasterxml.jackson.annotation.JsonTypeName;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.query.QueryView;
import org.labkey.api.util.UnexpectedException;

/**
 * Renders a QueryView as JSON-ified HTML and context metadata (including JavaScript and CSS dependencies).
 *
 * User: jeckels
 * Date: 5/29/13
 */
@JsonTypeName("grid")
public class QueryWebPartDataRenderer extends AbstractQueryViewReportDataRenderer
{
    @Override
    protected ApiResponse createApiResponse(QueryView view)
    {
        try
        {
            return view.renderToApiResponse();
        }
        catch (RuntimeException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new UnexpectedException(e);
        }
    }
}
