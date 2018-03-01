/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
package org.labkey.ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource; import org.labkey.api.module.Module;
import java.sql.SQLException;

/**
 * User: bimber
 * Date: 2/17/13
 * Time: 4:52 PM
 */
public class DefaultBloodDrawDataSource extends AbstractDataSource
{
    public DefaultBloodDrawDataSource(Module module)
    {
        super("study", "Blood Draws", "Blood Draw", "Blood Draws", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        sb.append(safeAppend(rs, "Total Quantity", "quantity"));
        sb.append(safeAppend(rs, "Charge Unit", "billedby"));
        sb.append(safeAppend(rs, "Tube Type", "tube_type"));
        sb.append(safeAppend(rs, "# of Tubes", "num_tubes"));
        sb.append(safeAppend(rs, "Sample Type", "sampletype"));

        //NOTE: not really sensitive, but also not necessary to publish
        if (!redacted)
        {
            sb.append(safeAppend(rs, "Additional Services", "additionalServices"));
        }

        return sb.toString();
    }
}
