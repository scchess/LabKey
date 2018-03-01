/*
 * Copyright (c) 2009 LabKey Corporation
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
package org.labkey.remoteapi.query;

import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.CommandException;

import java.io.IOException;

/**
 * User: adam
 * Date: Feb 27, 2009
 * Time: 11:06:20 AM
 */

// Common methods implemented by SelectRowsCommand and ExecuteSqlCommand.  Makes implementing SAS wrapper classes much easier.
public interface BaseSelect
{
    int getMaxRows();

    void setMaxRows(int maxRows);

    int getOffset();

    void setOffset(int offset);

    ContainerFilter getContainerFilter();

    void setContainerFilter(ContainerFilter containerFilter);

    SelectRowsResponse execute(Connection connection, String folderPath) throws IOException, CommandException;

    double getRequiredVersion();

    void setRequiredVersion(double requiredVersion);
}
