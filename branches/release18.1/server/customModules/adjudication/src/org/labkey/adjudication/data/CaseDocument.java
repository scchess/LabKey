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
package org.labkey.adjudication.data;

import org.labkey.api.attachments.AttachmentFile;
import org.labkey.api.data.Entity;

/**
 * Created by klum on 6/15/2017.
 */
public class CaseDocument extends Entity
{
    private Integer _caseId;
    private AttachmentFile _document;
    private String _documentName;

    public Integer getCaseId()
    {
        return _caseId;
    }

    public void setCaseId(Integer caseId)
    {
        _caseId = caseId;
    }

    public AttachmentFile getDocument()
    {
        return _document;
    }

    public void setDocument(AttachmentFile document)
    {
        _document = document;
    }

    public String getDocumentName()
    {
        return _documentName;
    }

    public void setDocumentName(String documentName)
    {
        _documentName = documentName;
    }
}
