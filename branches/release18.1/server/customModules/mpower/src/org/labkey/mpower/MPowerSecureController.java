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
package org.labkey.mpower;

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Container;
import org.labkey.api.security.CSRF;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.Permission;
import org.labkey.mpower.model.SurveyParticipant;
import org.labkey.mpower.model.SurveyResponse;
import org.labkey.mpower.security.MPowerSecureSubmitter;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

import java.util.Set;

/**
 * Created by klum on 6/22/15.
 */
public class MPowerSecureController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(
            MPowerSecureController.class,
            SecureSaveSurveyResponseAction.class);

    public static final String NAME = "mpower-secure";

    public MPowerSecureController()
    {
        setActionResolver(_actionResolver);
    }

    /**
     * Action which accepts user consent information (name, DOB) from the mpower public controller (separate server)
     * stores the information and returns a token which is subsequently used to associate survey responses to the
     * original user.
     */
    @RequiresPermission(MPowerSecureSubmitter.class)
    @CSRF
    public static class CreateUserTokenAction extends MutatingApiAction<SurveyParticipant>
    {
        @Override
        public void validateForm(SurveyParticipant participant, Errors errors)
        {
            validatePermission(getUser(), getContainer(), errors);
            if (StringUtils.isBlank(participant.getFirstName()))
            {
                errors.reject("First name is required");
            }

            if (StringUtils.isBlank(participant.getLastName()))
            {
                errors.reject("Last name is required");
            }

            if (StringUtils.isBlank(participant.getSignature()))
            {
                errors.reject("Signature is required");
            }
        }

        @Override
        public ApiResponse execute(SurveyParticipant form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();

            String guid = MPowerManager.get().saveSurveyParticipant(getUser(), getContainer(), form);
            response.put("guid", guid);

            return response;
        }
    }

    /**
     * Action which verifies that the specified user token is valid, prevents spamming the public server to gain access
     * to the survey questionaire.
     */
    @RequiresPermission(MPowerSecureSubmitter.class)
    @CSRF
    public static class VerifyUserTokenAction extends MutatingApiAction<SurveyResponse>
    {
        @Override
        public ApiResponse execute(SurveyResponse form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();

            SurveyParticipant participant = MPowerManager.get().getSurveyParticipant(getUser(), getContainer(), form.getToken());
            response.put("success", participant != null);

            return response;
        }
    }

    static void validatePermission(User user, Container container, Errors errors)
    {
        Set<Class<? extends Permission>> permissionSet = container.getPolicy().getPermissions(user, null);

        if (permissionSet.size() == 1)
        {
            if (permissionSet.iterator().next().equals(MPowerSecureSubmitter.class))
            {
                return;
            }
        }
        errors.reject("The configured account in the secure MPower server can only be assigned the single MPower Secure Submitter security role.");
    }
}
