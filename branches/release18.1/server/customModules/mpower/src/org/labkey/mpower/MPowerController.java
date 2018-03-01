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

import org.apache.http.HttpStatus;
import org.apache.log4j.Logger;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.survey.model.SurveyDesign;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.mpower.model.SurveyParticipant;
import org.labkey.mpower.remote.CreateUserTokenCommand;
import org.labkey.mpower.remote.CreateUserTokenResponse;
import org.labkey.mpower.remote.VerifyUserTokenCommand;
import org.labkey.mpower.remote.VerifyUserTokenResponse;
import org.labkey.remoteapi.Connection;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

public class MPowerController extends SpringActionController
{
    private static final Logger _log = Logger.getLogger(MPowerController.class);

    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(
            MPowerController.class,
            PublicSaveSurveyResponseAction.class);

    public static final String NAME = "mpower";

    public MPowerController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public class BeginAction extends SimpleViewAction<Object>
    {
        @Override
        public ModelAndView getView(Object o, BindException errors) throws Exception
        {
            return new JspView<>("/org/labkey/mpower/view/consentPage.jsp");
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("MPower");
        }
    }

    /**
     * Action which posts user consent information (name, DOB) to the mpower secure controller (separate server)
     * via the java api and returns a token which is subsequently used to associate survey responses to the
     * original user.
     */
    @RequiresPermission(ReadPermission.class)
    public class CreateUserTokenAction extends MutatingApiAction<SurveyParticipant>
    {
        @Override
        public ApiResponse execute(SurveyParticipant form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();
            MPowerManager.RemoteConnectionInfo info = MPowerManager.get().getRemoteConnectionInfo(getContainer());

            if (info != null)
            {
                Connection cn = new Connection(info.getUrl(), info.getUser(), info.getPassword());
                CreateUserTokenCommand command = new CreateUserTokenCommand(form);
                CreateUserTokenResponse commandResponse = command.execute(cn, info.getContainer());

                if (commandResponse.getStatusCode() == HttpStatus.SC_OK)
                {
                    String guid = commandResponse.getGUID();

                    response.put("token", guid);
                    response.put("redirectURL", new ActionURL(CreateSurveyAction.class, getContainer()).addParameter("token", guid));
                    response.put("success", true);
                }
            }
            return response;
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class CreateSurveyAction extends SimpleViewAction<CreateSurvey>
    {
        @Override
        public ModelAndView getView(CreateSurvey form, BindException errors) throws Exception
        {
            // verify the user token first
            MPowerManager.RemoteConnectionInfo info = MPowerManager.get().getRemoteConnectionInfo(getContainer());
            boolean tokenValid = false;

            if (info != null)
            {
                Connection cn = new Connection(info.getUrl(), info.getUser(), info.getPassword());
                VerifyUserTokenCommand command = new VerifyUserTokenCommand(form);
                VerifyUserTokenResponse commandResponse = command.execute(cn, info.getContainer());

                if (commandResponse.getStatusCode() == HttpStatus.SC_OK)
                {
                    tokenValid = commandResponse.getSuccess();
                }
            }

            if (tokenValid)
            {
                // use the survey metadata from the mpower module
                form.setDesignId("module:mpower/participant");
                return new JspView<>("/org/labkey/mpower/view/surveyPage.jsp", form, errors);
            }
            else
            {
                return new HtmlView("<div class='labkey-error'>An Invalid User Token was Specified.</div>");
            }
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("MPower Survey");
        }
    }

    public static class CreateSurvey
    {
        private String _token;
        private String _designId;

        public String getToken()
        {
            return _token;
        }

        public void setToken(String token)
        {
            _token = token;
        }

        public String getDesignId()
        {
            return _designId;
        }

        public void setDesignId(String designId)
        {
            _designId = designId;
        }
    }
}