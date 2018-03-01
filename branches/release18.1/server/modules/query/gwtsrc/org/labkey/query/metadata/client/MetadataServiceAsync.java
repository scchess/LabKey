/*
 * Copyright (c) 2008 LabKey Corporation
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

package org.labkey.query.metadata.client;

import com.google.gwt.user.client.rpc.AsyncCallback;
import org.labkey.api.gwt.client.ui.LookupServiceAsync;

public interface MetadataServiceAsync extends LookupServiceAsync
{
    void getMetadata(String schema, String table, AsyncCallback<GWTTableInfo> async);

    void saveMetadata(GWTTableInfo domain, String schema, AsyncCallback<GWTTableInfo> async);

    void resetToDefault(String schemaName, String queryName, AsyncCallback<GWTTableInfo> asyncCallback);
}
