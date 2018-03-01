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
package org.labkey.mpower.remote;

import org.json.simple.JSONObject;
import org.labkey.mpower.MPowerSecureController;
import org.labkey.mpower.model.SurveyResponse;
import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.PostCommand;

/**
 * Created by klum on 6/22/15.
 */
public class SaveSurveyResponseCommand extends PostCommand<CommandResponse>
{
    SurveyResponse _response;

    public SaveSurveyResponseCommand(SurveyResponse response)
    {
        super(MPowerSecureController.NAME, "saveSurveyResponse");
        _response = response;
    }

    public SaveSurveyResponseCommand(SaveSurveyResponseCommand source)
    {
        super(source);
        _response = source.getResponse();
    }

    public SurveyResponse getResponse()
    {
        return _response;
    }

    @Override
    public JSONObject getJsonObject()
    {
        JSONObject obj = new JSONObject();

        obj.put("token", _response.getToken());
        obj.put("responses", _response.getResponses());

        return obj;
    }

    @Override
    public PostCommand copy()
    {
        return new SaveSurveyResponseCommand(this);
    }
}
