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
import org.labkey.api.util.GUID;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by klum on 6/22/15.
 */
public class SurveyResponse extends Entity
{
    protected String _responsesPk;  // the security token used to associate the survey participant
    private int _surveyDesignId;
    private Map<String, Object> _responses = new HashMap<>();

    public String getToken()
    {
        return _responsesPk;
    }

    public void setToken(String token)
    {
        _responsesPk = token;
    }

    public String getResponsesPk()
    {
        return _responsesPk;
    }

    public void setResponsesPk(String responsesPk)
    {
        _responsesPk = responsesPk;
    }

    public int getSurveyDesignId()
    {
        return _surveyDesignId;
    }

    public void setSurveyDesignId(int surveyDesignId)
    {
        _surveyDesignId = surveyDesignId;
    }

    public Map<String, Object> getResponses()
    {
        return _responses;
    }

    public void setResponses(Map<String, Object> responses)
    {
        _responses = responses;
    }
}
