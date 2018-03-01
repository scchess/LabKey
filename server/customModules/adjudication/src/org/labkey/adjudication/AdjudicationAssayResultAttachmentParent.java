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

import org.jetbrains.annotations.NotNull;
import org.labkey.api.attachments.AttachmentParent;
import org.labkey.api.attachments.AttachmentType;
import org.labkey.api.data.Container;

public class AdjudicationAssayResultAttachmentParent implements AttachmentParent
{
    private final Container _c;
    private final String _entityId;

    // Passing in Container and EntityId because there's no object that represents an AdjudicationAssayResult
    // (e.g., an Entity). This is called by a single code path that checks container permissions, retrieves the
    // provisioned adjudication table for that container, and then filters to the requested RowId or EntityId.
    public AdjudicationAssayResultAttachmentParent(Container c, String entityId)
    {
        _c = c;
        _entityId = entityId;
    }

    @Override
    public String getEntityId()
    {
        return _entityId;
    }

    @Override
    public String getContainerId()
    {
        return _c.getId();
    }

    @Override
    public @NotNull AttachmentType getAttachmentType()
    {
        return AdjudicationAssayResultType.get();
    }
}
