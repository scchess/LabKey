/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
import org.labkey.api.util.DateUtil;
import org.labkey.mpower.MPowerSecureController;
import org.labkey.mpower.model.SurveyParticipant;
import org.labkey.remoteapi.PostCommand;

/**
 * Created by klum on 6/22/15.
 */
public class CreateUserTokenCommand extends PostCommand<CreateUserTokenResponse>
{
    private SurveyParticipant _participant;

    public CreateUserTokenCommand(SurveyParticipant participant)
    {
        super(MPowerSecureController.NAME, "createUserToken");
        _participant = participant;
    }

    public CreateUserTokenCommand(CreateUserTokenCommand source)
    {
        super(source);
        _participant = source.getParticipant();
    }

    public SurveyParticipant getParticipant()
    {
        return _participant;
    }

    @Override
    protected CreateUserTokenResponse createResponse(String text, int status, String contentType, JSONObject json)
    {
        return new CreateUserTokenResponse(text, status, contentType, json, this);
    }

    @Override
    public JSONObject getJsonObject()
    {
        JSONObject obj = new JSONObject();

        obj.put("firstName", _participant.getFirstName());
        obj.put("lastName", _participant.getLastName());
        obj.put("middleName", _participant.getMiddleName());
        obj.put("birthDate", DateUtil.toISO(_participant.getBirthDate()));
        obj.put("email", _participant.getEmail());
        obj.put("arm1Consent", _participant.isArm1Consent());
        obj.put("arm2Consent", _participant.isArm2Consent());
        obj.put("futureResearchConsent", _participant.isFutureResearchConsent());
        obj.put("signature", _participant.getSignature());

        return obj;
    }

    @Override
    public PostCommand copy()
    {
        return new CreateUserTokenCommand(this);
    }
}
