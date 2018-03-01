/*
 * Copyright (c) 2014-2016 LabKey Corporation
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
package org.labkey.test.pages.targetedms;

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.components.targetedms.QCAnnotationTypeWebPart;
import org.labkey.test.components.targetedms.QCAnnotationWebPart;
import org.labkey.test.pages.PortalBodyPanel;

public class PanoramaAnnotations extends PortalBodyPanel
{
    private QCAnnotationWebPart _qcAnnotationWebPart;
    private QCAnnotationTypeWebPart _qcAnnotationTypeWebPart;

    public PanoramaAnnotations(BaseWebDriverTest test)
    {
        super(test.getDriver());
        _qcAnnotationWebPart = new QCAnnotationWebPart(test);
        _qcAnnotationTypeWebPart = new QCAnnotationTypeWebPart(test);
    }

    public QCAnnotationWebPart getQcAnnotationWebPart()
    {
        return _qcAnnotationWebPart;
    }

    public QCAnnotationTypeWebPart getQcAnnotationTypeWebPart()
    {
        return _qcAnnotationTypeWebPart;
    }
}
