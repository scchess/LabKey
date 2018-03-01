/*
 * Copyright (c) 2007-2013 LabKey Corporation
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

package org.labkey.flow.controllers;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class NewFolderForm
{
    private String _folderName;
    private Set<String> _copyAnalysisScript = Collections.emptySet();
    private boolean _copyProtocol;

    public void setFolderName(String name)
    {
        _folderName = name;
    }

    public String getFolderName()
    {
        return _folderName;
    }

    public void setCopyAnalysisScript(String[] analysisScript)
    {
        _copyAnalysisScript = new HashSet<>(Arrays.asList(analysisScript));
    }

    public Set<String> getCopyAnalysisScript()
    {
        return _copyAnalysisScript;
    }

    public void setCopyProtocol(boolean b)
    {
        _copyProtocol = b;
    }

    public boolean isCopyProtocol()
    {
        return _copyProtocol;
    }

}
