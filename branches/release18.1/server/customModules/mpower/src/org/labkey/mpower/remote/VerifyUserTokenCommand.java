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
import org.labkey.mpower.MPowerController;
import org.labkey.mpower.MPowerSecureController;
import org.labkey.remoteapi.PostCommand;

/**
 * Created by klum on 8/18/2015.
 */
public class VerifyUserTokenCommand extends PostCommand<VerifyUserTokenResponse>
{
    MPowerController.CreateSurvey _createSurvey;

    public VerifyUserTokenCommand(MPowerController.CreateSurvey createSurvey)
    {
        super(MPowerSecureController.NAME, "verifyUserToken");
        _createSurvey = createSurvey;
    }

    public VerifyUserTokenCommand(VerifyUserTokenCommand source)
    {
        super(source);
        _createSurvey = source.getCreateSurvey();
    }

    public MPowerController.CreateSurvey getCreateSurvey()
    {
        return _createSurvey;
    }

    @Override
    protected VerifyUserTokenResponse createResponse(String text, int status, String contentType, JSONObject json)
    {
        return new VerifyUserTokenResponse(text, status, contentType, json, this);
    }

    @Override
    public JSONObject getJsonObject()
    {
        JSONObject obj = new JSONObject();

        obj.put("token", _createSurvey.getToken());

        return obj;
    }

    @Override
    public PostCommand copy()
    {
        return new VerifyUserTokenCommand(this);
    }
}
