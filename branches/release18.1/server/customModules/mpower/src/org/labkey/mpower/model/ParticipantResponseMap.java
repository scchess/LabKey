/*
 * Copyright (c) 2015 LabKey Corporation
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
package org.labkey.mpower.model;

import org.labkey.api.data.Entity;

/**
 * Created by klum on 6/28/15.
 */
public class ParticipantResponseMap extends Entity
{
    private int _participantId;
    private String _GUID;

    public int getParticipantId()
    {
        return _participantId;
    }

    public void setParticipantId(int participantId)
    {
        _participantId = participantId;
    }

    public String getGUID()
    {
        return _GUID;
    }

    public void setGUID(String GUID)
    {
        _GUID = GUID;
    }
}
