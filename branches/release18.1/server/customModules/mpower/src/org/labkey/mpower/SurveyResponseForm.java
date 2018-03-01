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
package org.labkey.mpower;

import org.json.JSONObject;
import org.labkey.api.action.CustomApiForm;
import org.labkey.mpower.model.SurveyResponse;

import java.util.Map;

/**
 * Created by klum on 8/12/2015.
 */
public class SurveyResponseForm extends SurveyResponse implements CustomApiForm
{
    @Override
    public void bindProperties(Map<String, Object> props)
    {
        if (props.containsKey("responsesPk"))
            setResponsesPk(String.valueOf(props.get("responsesPk")));
        if (props.containsKey("token"))
            setToken(String.valueOf(props.get("token")));

        if (props.containsKey("responses"))
            setResponses((JSONObject)props.get("responses"));
    }
}
